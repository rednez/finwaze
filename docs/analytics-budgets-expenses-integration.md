# Plan: BudgetsExpensesCard — DB Integration

## Context

The `app-budgets-expenses-card` widget (bar chart, Budgets vs Expenses) is fully built but renders hardcoded mock data. This plan wires it to the database: it reacts to the page-level **Currency** filter (`AnalyticsStore.selectedCurrencyCode`) and its own widget-level **Year** datepicker, fetching 12 monthly aggregates (planned budget vs actual expense) from a new SQL function. Data reloads on every route visit and on any filter change. No loading skeleton is needed — the chart renders gracefully with empty arrays while fetching.

---

## Files Created

| Path | Description |
|---|---|
| `src/app/features/analytics/models/monthly-budget-expense.ts` | `MonthlyBudgetExpense` interface |
| `src/app/features/analytics/ui/budget-expenses-card/budgets-expenses-card-store.ts` | Component-scoped NgRx SignalStore |

## Files Modified

| Path | Change |
|---|---|
| `supabase/schemas/monthly_budgets_funcs.sql` | Added `get_yearly_budgets_vs_expenses` SQL function |
| `src/app/features/analytics/models/index.ts` | Exported `MonthlyBudgetExpense` |
| `src/app/features/analytics/repositories/analytics-repository.ts` | Added `getYearlyBudgetsVsExpenses` method |
| `src/app/features/analytics/ui/budget-expenses-card/budgets-expenses-card.ts` | Replaced mock signals with store |

---

## SQL Function

Added to **`supabase/schemas/monthly_budgets_funcs.sql`**:

```sql
CREATE OR REPLACE FUNCTION public.get_yearly_budgets_vs_expenses(
  p_year          INT,
  p_currency_code TEXT
)
RETURNS TABLE (
  month          DATE,
  budget_amount  NUMERIC,
  expense_amount NUMERIC
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
```

### How it works

- Generates a full 12-month series via `generate_series` so every month is always present.
- **Budget CTE**: sums `monthly_budgets.planned_amount` joined to non-system groups for the given year and currency.
- **Expense CTE**: sums `ABS(charged_amount)` from transactions joined via `account → currency`, excluding `transfer` and `internal` types, filtering on `charged_amount < 0` (sign-based, not `type`-based per project rules).
- Both CTEs are `LEFT JOIN`ed onto the months series; missing values default to `0`.

### Design decisions

| Decision | Reason |
|---|---|
| `charged_amount < 0` for expenses | CLAUDE.md rule: use sign of amount, not `type = 'expense'` |
| `account → currency` join | Budgets are in account currency; expenses should match |
| `make_date` range instead of `EXTRACT(YEAR)` | Better index utilization |
| `generate_series` for months | Ensures all 12 months always appear, even with no data |

---

## TypeScript Model

```typescript
// src/app/features/analytics/models/monthly-budget-expense.ts
export interface MonthlyBudgetExpense {
  month: string; // YYYY-MM-DD (first day of month)
  budgetAmount: number;
  expenseAmount: number;
}
```

---

## Repository Method

```typescript
// analytics-repository.ts
async getYearlyBudgetsVsExpenses(
  year: number,
  currencyCode: string,
): Promise<MonthlyBudgetExpense[]>
```

Calls `get_yearly_budgets_vs_expenses` RPC with `p_year` (integer) and `p_currency_code`.

---

## BudgetsExpensesCardStore

Component-scoped store (no `providedIn: 'root'`) — re-created on every route visit.

**State:**
- `yearlyData: MonthlyBudgetExpense[]` — the 12-month dataset
- `selectedYear: Date` — the widget's own year filter

**Computed:**
- `labels()` — month strings passed to the chart (formatted to `MMM` by the chart component)
- `expenses()` — expense amounts per month
- `budgets()` — budget amounts per month

**Reactivity:** An `effect` in `onInit` tracks both `selectedYear` and `AnalyticsStore.selectedCurrencyCode`. Either change triggers a fresh load.

---

## Verification

1. Open the analytics page — chart loads 12 months of data for the current year.
2. Change Currency filter — chart reloads with data for the new currency.
3. Change Year in the widget datepicker — chart reloads with data for the new year.
4. Navigate away and back to analytics — chart data reloads (store is re-created on route visit).
5. Months with no budgets/expenses show `0` bars.
