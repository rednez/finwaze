# Analytics: Monthly Overview Card — DB Integration

## Purpose

The `FinancialMonthlyOverviewCard` widget displays a line chart with two series — the selected month and the previous month — for daily financial data. A selector on the card lets the user switch between three views:

- **Total balance** — running cumulative balance per day (includes all transaction types)
- **Total income** — daily income amounts (excludes transfer and internal)
- **Total expenses** — daily expense amounts (excludes transfer and internal)

The widget is driven by the shared analytics filters (Month, Currency, Accounts) already managed by `AnalyticsStore`.

---

## SQL Function: `get_daily_financial_overview_for_month`

**File:** `supabase/schemas/charts_funcs.sql`

### Signature

```sql
get_daily_financial_overview_for_month(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (day DATE, daily_income NUMERIC, daily_expense NUMERIC, running_balance NUMERIC)
```

### Design decisions

**Complete date series.** `generate_series` produces a row for every calendar day in the month, even days with no transactions (those return 0 for all amounts). This ensures the chart always has a continuous x-axis.

**Balance carry-in (`balance_before` CTE).** The running balance for day N = balance at the start of the month + cumulative daily net through day N. The carry-in is computed as `SUM(charged_amount)` over all transactions before the month start, with no type exclusion — transfers and internal adjustments all affect the actual balance.

**Income/expense exclude transfer and internal.** Only the balance calculation includes all transaction types. Income and expense aggregations use `FILTER (WHERE t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))`.

**Account filtering.** Optional `p_account_ids` parameter uses `t.account_id = ANY(p_account_ids)` with a null/empty guard, matching the pattern in `get_analytics_financial_summary`.

**`charged_amount` throughout.** All aggregations use `charged_amount` (the amount in the account's currency), consistent with the rest of the analytics layer.

**Window function for running balance.**
```sql
(SELECT balance FROM balance_before)
  + SUM(daily_net) OVER (ORDER BY day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
```

---

## Data Flow

```
Filter change (month / currency / accounts)
  → AnalyticsStore effect (withHooks)
    → loadFinancialSummary()  [existing]
    → loadDailyOverview()     [new]
      → Promise.all([
          getDailyOverview(selectedMonth, ...),
          getDailyOverview(previousMonth, ...)
        ])
      → patchState({ dailyOverview, previousDailyOverview })

FinancialMonthlyOverviewCard
  → reads store.dailyOverview() + store.previousDailyOverview()
  → computed signals map to chart arrays based on selected type
  → passes arrays to FinancialMonthlyOverviewChart with labelFormat="d"
```

---

## Files Changed

| File | Change |
|------|--------|
| `supabase/schemas/charts_funcs.sql` | Added `get_daily_financial_overview_for_month` |
| `src/app/features/analytics/models/daily-data-point.ts` | New `DailyDataPoint` interface |
| `src/app/features/analytics/models/index.ts` | Exports `DailyDataPoint` |
| `src/app/features/analytics/repositories/analytics-repository.ts` | Added `getDailyOverview` method |
| `src/app/features/analytics/stores/analytics-store.ts` | Added `dailyOverview`, `previousDailyOverview`, `isDailyOverviewLoading` state + `loadDailyOverview` method |
| `src/app/features/analytics/ui/financial-monthly-overview-chart/financial-monthly-overview-chart.ts` | Added `labelFormat` input (default `'MMM'`) |
| `src/app/features/analytics/ui/financial-monthly-overview-card/financial-monthly-overview-card.ts` | Replaced hardcoded data with store-driven computed signals |
| `src/app/features/analytics/ui/financial-monthly-overview-card/financial-monthly-overview-card.spec.ts` | Full test suite with mock store |
