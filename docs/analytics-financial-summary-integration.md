# Plan: Analytics Financial Summary — DB Integration

## Context
The analytics feature has fully built UI components (StatsFilters, FinancialSummaryCard × 3) but all data is hardcoded. This plan wires them to the database: filters (month, currency from user's accounts, accounts multiselect) drive a new Supabase RPC that returns income/expense/balance totals for the selected period. Loading behavior mirrors the goals/dashboard pattern — skeletons on first visit, background refresh on subsequent visits.

---

## Files to Create

| Path | Description |
|---|---|
| `src/app/features/analytics/models/financial-summary.ts` | `FinancialSummary` interface |
| `src/app/features/analytics/models/index.ts` | Barrel |
| `src/app/features/analytics/repositories/analytics-repository.ts` | `AnalyticsRepository` |
| `src/app/features/analytics/repositories/index.ts` | Barrel |
| `src/app/features/analytics/stores/analytics-store.ts` | `AnalyticsStore` (NgRx SignalStore) |
| `src/app/features/analytics/stores/index.ts` | Barrel |

## Files to Modify

| Path | Change |
|---|---|
| `src/app/features/analytics/ui/stats-filters/stats-filters.ts` | Inject `AccountsStore` + `AnalyticsStore`; replace hardcoded signals with `computed`/`linkedSignal`; add `ngOnInit` currency init; add change handlers |
| `src/app/features/analytics/ui/stats-filters/stats-filters.html` | Replace `[(ngModel)]` with `[ngModel]` + `(ngModelChange)` for all 3 controls |
| `src/app/features/analytics/analytics.ts` | Inject `AnalyticsStore`; add `SkeletonModule`; bg-refresh in constructor |
| `src/app/features/analytics/analytics.html` | Wrap summary cards in `@if (store.isLoading())` skeletons / `@else` real cards bound to store |

---

## 1. SQL Function

Add to the end of **`supabase/schemas/charts_funcs.sql`** (alongside `get_dashboard_totals`, `get_monthly_transaction_amounts_by_group`). You will create the migration yourself.

```sql
CREATE OR REPLACE FUNCTION public.get_analytics_financial_summary(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  monthly_income            NUMERIC,
  previous_monthly_income   NUMERIC,
  monthly_expense           NUMERIC,
  previous_monthly_expense  NUMERIC,
  total_balance             NUMERIC,
  previous_total_balance    NUMERIC,
  income_transaction_count  BIGINT,
  expense_transaction_count BIGINT,
  income_groups_count       BIGINT,
  expense_groups_count      BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_currency_id BIGINT;
  v_month_start TIMESTAMP;
  v_month_end   TIMESTAMP;
  v_prev_start  TIMESTAMP;
  v_prev_end    TIMESTAMP;
BEGIN
  SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;

  v_month_start := date_trunc('month', p_month::TIMESTAMP);
  v_month_end   := v_month_start + INTERVAL '1 month';
  v_prev_start  := v_month_start - INTERVAL '1 month';
  v_prev_end    := v_month_start;

  RETURN QUERY
  SELECT
    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end)), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_prev_end), 0),

    COUNT(*)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(*)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)

  FROM public.transactions t
  JOIN public.categories cat ON cat.id = t.category_id
  WHERE t.charged_currency_id = v_currency_id
    AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
    AND (
      p_account_ids IS NULL
      OR cardinality(p_account_ids) = 0
      OR t.account_id = ANY(p_account_ids)
    );
END;
$$;
```

Key rules followed: `FILTER (WHERE …)` aggregates, `(transacted_at + local_offset)`, `NOT IN ('transfer', 'internal')`, `NUMERIC`, `search_path = ''`, `STABLE SECURITY INVOKER`, account filter pattern matches `get_filtered_transactions`.

---

## 2. Model

**`src/app/features/analytics/models/financial-summary.ts`**
```typescript
export interface FinancialSummary {
  monthlyIncome: number;
  previousMonthlyIncome: number;
  monthlyExpense: number;
  previousMonthlyExpense: number;
  totalBalance: number;
  previousTotalBalance: number;
  incomeTransactionCount: number;
  expenseTransactionCount: number;
  incomeGroupsCount: number;
  expenseGroupsCount: number;
}
```

---

## 3. Repository

**`src/app/features/analytics/repositories/analytics-repository.ts`**

`@Injectable({ providedIn: 'root' })` — injects `SupabaseService`.

`getFinancialSummary(month: Date, currencyCode: string, accountIds: number[]): Promise<FinancialSummary>`:
- calls `.rpc('get_analytics_financial_summary', { p_month: format(month, 'yyyy-MM-dd'), p_currency_code: currencyCode, p_account_ids: accountIds.length ? accountIds : null })`
- maps DTO (snake_case) → model (camelCase) inline (single method, no separate mapper needed)

Date formatting: use `format(month, 'yyyy-MM-dd')` from `date-fns` (check if dayjs or date-fns is used in existing repositories — adjust accordingly).

---

## 4. Store

**`src/app/features/analytics/stores/analytics-store.ts`**

Pattern: identical to `GoalsListStore` / `SavingsOverviewStore`.

```typescript
interface AnalyticsState {
  isLoading: boolean;    // true → show skeletons
  isLoaded: boolean;
  isUpdating: boolean;   // true → bg refresh (no skeletons)
  isError: boolean;
  selectedMonth: Date;
  selectedCurrencyCode: string;  // '' until StatsFilters.ngOnInit sets it
  selectedAccountIds: number[];
  financialSummary: FinancialSummary | null;
}

const initialState = {
  isLoading: true,   // start with skeletons
  isLoaded: false,
  ...
  selectedCurrencyCode: '',
  selectedAccountIds: [],
  financialSummary: null,
};
```

`loadFinancialSummary()`:
- `isLoaded()` → `patchState({ isUpdating: true })`, else `patchState({ isLoading: true })`
- calls repository, patches result + `isLoaded: true, isLoading: false, isUpdating: false`

Update methods: `updateMonth`, `updateCurrencyCode`, `updateAccountIds`.

`withHooks.onInit`: 
```typescript
effect(() => {
  store.selectedMonth();
  store.selectedCurrencyCode();
  store.selectedAccountIds();
  untracked(() => {
    if (store.selectedCurrencyCode()) store.loadFinancialSummary();
  });
});
```
Guard `if (selectedCurrencyCode())` prevents spurious load before `StatsFilters.ngOnInit` sets initial currency.

---

## 5. StatsFilters

**`stats-filters.ts`**: inject `AccountsStore` + `AnalyticsStore`.
- `currencies = computed(() => accountsStore.myCurrencies().map(c => ({ name: c })))`
- `accounts = computed(() => accountsStore.accounts())`
- `month = linkedSignal(() => analyticsStore.selectedMonth())`
- `currency = linkedSignal<{name:string}>(() => ({ name: analyticsStore.selectedCurrencyCode() }))`
- `selectedAccounts = linkedSignal<Account[]>(() => accountsStore.accounts().filter(a => analyticsStore.selectedAccountIds().includes(a.id)))`
- `ngOnInit`: if `!analyticsStore.selectedCurrencyCode()` → `analyticsStore.updateCurrencyCode(accountsStore.selectedCurrencyCode()!)`
- Change handlers: `onMonthChange`, `onCurrencyChange`, `onAccountsChange` → call store update methods

**`stats-filters.html`**: replace `[(ngModel)]` with `[ngModel]="..." (ngModelChange)="..."` for all 3 controls.

---

## 6. Analytics Component + Template

**`analytics.ts`**:
- Add `inject(AnalyticsStore)` as `protected readonly store`
- Add `SkeletonModule` to imports
- Constructor: `if (this.store.isLoaded()) { this.store.loadFinancialSummary(); }`

**`analytics.html`** — replace the 3-card `<div>` with:
```html
<div class="flex gap-4 flex-wrap">
  @if (store.isLoading()) {
    @for (i of [1, 2, 3]; track i) {
      <p-skeleton class="grow rounded-3xl h-48" />
    }
  } @else {
    <app-financial-summary-card
      title="Total balance"
      [currentAmount]="store.financialSummary()?.totalBalance ?? 0"
      [previousAmount]="store.financialSummary()?.previousTotalBalance ?? 0"
      [currency]="store.selectedCurrencyCode()"
      [growTrendIsGood]="true"
      infoTextPart="You have extra"
      [transactionCount]="(store.financialSummary()?.incomeTransactionCount ?? 0) + (store.financialSummary()?.expenseTransactionCount ?? 0)"
      [groupsCount]="(store.financialSummary()?.incomeGroupsCount ?? 0) + (store.financialSummary()?.expenseGroupsCount ?? 0)"
    />
    <app-financial-summary-card
      title="Income"
      [currentAmount]="store.financialSummary()?.monthlyIncome ?? 0"
      [previousAmount]="store.financialSummary()?.previousMonthlyIncome ?? 0"
      [currency]="store.selectedCurrencyCode()"
      [growTrendIsGood]="true"
      infoTextPart="You earn extra"
      [transactionCount]="store.financialSummary()?.incomeTransactionCount ?? 0"
      [groupsCount]="store.financialSummary()?.incomeGroupsCount ?? 0"
    />
    <app-financial-summary-card
      title="Expense"
      [currentAmount]="store.financialSummary()?.monthlyExpense ?? 0"
      [previousAmount]="store.financialSummary()?.previousMonthlyExpense ?? 0"
      [currency]="store.selectedCurrencyCode()"
      [growTrendIsGood]="false"
      infoTextPart="You have extra"
      [transactionCount]="store.financialSummary()?.expenseTransactionCount ?? 0"
      [groupsCount]="store.financialSummary()?.expenseGroupsCount ?? 0"
    />
  }
</div>
```
The other two sections (monthly overview, budgets/expenses + statistics) are left unchanged.

---

## Verification

1. Navigate to `/analytics` — 3 skeleton blocks should appear
2. Once loaded, 3 cards show real data for current month + selected currency
3. Change month → cards reload (no skeletons, background update)
4. Change currency → cards reload
5. Select/deselect accounts → cards reload
6. Navigate away and back → data refreshes in background (no skeletons)
7. Run `pnpm test` to verify no regressions
