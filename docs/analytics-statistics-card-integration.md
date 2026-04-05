# Analytics Statistics Card — DB Integration Plan

## Context

The `AnalyticStatisticsCard` widget exists and is fully rendered (donut chart + group legend
with a type selector for Expenses / Income / Budget), but all data is hardcoded in local signals.

This plan wires the widget to real Supabase data using the existing page-level filters
(Month, Currency, Accounts) from `AnalyticsStore`. When any filter changes the card must
refresh automatically alongside the other analytics widgets.

There is also a pre-existing bug: `displayedItems` returns `incomes` when the type is
`'Expenses'` and vice-versa. This is fixed as part of the integration.
A second bug: `type` is a plain property, so `computed(() => ...)` cannot track its changes,
meaning the donut chart never updates when the user switches between Expenses / Income / Budget.
This is fixed by converting `type` to a `signal`.

---

## 1. SQL Function — `get_analytics_amounts_by_groups`

**File:** `supabase/schemas/charts_funcs.sql`

Append to the end of the file. Returns total income and expense amounts per non-system group
for the selected month, currency and optional account filter. Mirrors the conventions of
`get_analytics_financial_summary`.

```sql
-- Returns total income and expense amounts per non-system group for a given month,
-- currency, and optional account filter. Used by the Statistics card donut chart.
CREATE OR REPLACE FUNCTION public.get_analytics_amounts_by_groups(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  group_id       BIGINT,
  group_name     TEXT,
  income_amount  NUMERIC,
  expense_amount NUMERIC
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  )
SELECT
  g.id                                                                            AS group_id,
  g.name                                                                          AS group_name,
  COALESCE(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount > 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)), 0)        AS income_amount,
  COALESCE(ABS(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount < 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))), 0)       AS expense_amount
FROM public.transactions t
JOIN public.categories   cat ON cat.id = t.category_id
JOIN public.groups       g   ON g.id   = cat.group_id
JOIN public.currencies   cur ON cur.id = t.charged_currency_id
CROSS JOIN month_start   ms
WHERE cur.code    = p_currency_code
  AND g.is_system = false
  AND (t.transacted_at + t.local_offset) >= ms.val
  AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  AND (
    p_account_ids IS NULL
    OR cardinality(p_account_ids) = 0
    OR t.account_id = ANY(p_account_ids)
  )
GROUP BY g.id, g.name
ORDER BY expense_amount DESC, g.name;
$$;
```

For **Budget**, re-use the existing `get_monthly_budgets_by_groups(p_month, p_currency_code)`
— budget entries are per-currency only, so no account filter applies.

---

## 2. New Model — `GroupAmount`

**New file:** `src/app/features/analytics/models/group-amount.ts`

```typescript
export interface GroupAmount {
  groupId: number;
  groupName: string;
  amount: number;
}
```

**Update:** `src/app/features/analytics/models/index.ts` — add export:

```typescript
export type { GroupAmount } from './group-amount';
```

---

## 3. Repository — `getGroupsStatistics`

**File:** `src/app/features/analytics/repositories/analytics-repository.ts`

Add two private DTOs and one public method. Both RPCs are called in parallel.

```typescript
// Private DTOs (add alongside existing ones)
interface GroupAmountDto {
  group_id: number;
  group_name: string;
  income_amount: number;
  expense_amount: number;
}

interface BudgetByGroupDto {
  group_id: number;
  group_name: string;
  planned_amount: number;
}

// New public method
async getGroupsStatistics(
  month: Date,
  currencyCode: string,
  accountIds: number[],
): Promise<{
  incomeByGroups: GroupAmount[];
  expenseByGroups: GroupAmount[];
  budgetByGroups: GroupAmount[];
}> {
  const formattedMonth = dayjs(month).format('YYYY-MM-DD');

  const [amountsResult, budgetsResult] = await Promise.all([
    this.supabase.client.rpc('get_analytics_amounts_by_groups', {
      p_month: formattedMonth,
      p_currency_code: currencyCode,
      p_account_ids: accountIds.length ? accountIds : null,
    }),
    this.supabase.client.rpc('get_monthly_budgets_by_groups', {
      p_month: formattedMonth,
      p_currency_code: currencyCode,
    }),
  ]);

  if (amountsResult.error) throw new Error(amountsResult.error.message);
  if (budgetsResult.error) throw new Error(budgetsResult.error.message);

  const amounts = amountsResult.data as GroupAmountDto[];
  const budgets = budgetsResult.data as BudgetByGroupDto[];

  return {
    incomeByGroups: amounts.map((row) => ({
      groupId: row.group_id,
      groupName: row.group_name,
      amount: row.income_amount,
    })),
    expenseByGroups: amounts.map((row) => ({
      groupId: row.group_id,
      groupName: row.group_name,
      amount: row.expense_amount,
    })),
    budgetByGroups: budgets.map((row) => ({
      groupId: row.group_id,
      groupName: row.group_name,
      amount: row.planned_amount,
    })),
  };
}
```

Also update the import at the top:

```typescript
import { DailyDataPoint, FinancialSummary, GroupAmount } from '../models';
```

---

## 4. Store — `AnalyticsStore`

**File:** `src/app/features/analytics/stores/analytics-store.ts`

### 4a. State interface additions

```typescript
incomeByGroups: GroupAmount[];
expenseByGroups: GroupAmount[];
budgetByGroups: GroupAmount[];
isGroupsStatisticsLoading: boolean;
```

### 4b. Initial state additions

```typescript
incomeByGroups: [],
expenseByGroups: [],
budgetByGroups: [],
isGroupsStatisticsLoading: false,
```

### 4c. New method inside `withMethods`

```typescript
async loadGroupsStatistics(): Promise<void> {
  patchState(store, { isGroupsStatisticsLoading: true });
  try {
    const { incomeByGroups, expenseByGroups, budgetByGroups } =
      await repository.getGroupsStatistics(
        store.selectedMonth(),
        store.selectedCurrencyCode(),
        store.selectedAccountIds(),
      );
    patchState(store, {
      incomeByGroups,
      expenseByGroups,
      budgetByGroups,
      isGroupsStatisticsLoading: false,
    });
  } catch {
    patchState(store, { isGroupsStatisticsLoading: false });
  }
},
```

### 4d. `onInit` effect update — add `store.loadGroupsStatistics()` call

```typescript
untracked(() => {
  if (store.selectedCurrencyCode()) {
    store.loadFinancialSummary();
    store.loadDailyOverview();
    store.loadGroupsStatistics();  // add this
  }
});
```

### 4e. Import update

```typescript
import { DailyDataPoint, FinancialSummary, GroupAmount } from '../models';
```

---

## 5. Component — `AnalyticStatisticsCard`

**File:** `src/app/features/analytics/ui/analytic-statistics-card/analytic-statistics-card.ts`

Changes:
- Inject `AnalyticsStore`
- Remove all hardcoded data signals (`incomes`, `expenses`, `budgets`, `currency`, `month`)
- Convert `type` from a plain property to a `signal<{ name: string }>` so that `displayedItems` reacts to dropdown changes (fixes the reactivity bug; use `[(ngModel)]` with a getter/setter or `model()`)
- Fix the swapped `displayedItems` bug: `Income → incomeByGroups`, `Expenses → expenseByGroups`, `Budget → budgetByGroups`
- Filter out zero-amount groups before assigning colors
- Add `@if (store.isGroupsStatisticsLoading())` skeleton wrapping the chart + legend
- Use `store.selectedCurrencyCode()` and `store.selectedMonth()` directly in template and computed
- Add `SkeletonModule` to `imports`

Full updated component:

```typescript
import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { generateAnalogColors } from '@core/utils/colors';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { SkeletonModule } from 'primeng/skeleton';
import { v4 } from 'uuid';
import { StatisticsByGroups } from './statistics-by-groups/statistics-by-groups';
import { AnalyticsStore } from '../../stores';

@Component({
  selector: 'app-analytic-statistics-card',
  imports: [
    CommonModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    SelectModule,
    FormsModule,
    DonutSummaryChart,
    SelectButtonModule,
    SkeletonModule,
    StatisticsByGroups,
  ],
  providers: [DatePipe],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Statistics</app-card-header-title>
        <p-select
          append-right
          [ngModel]="type()"
          (ngModelChange)="type.set($event)"
          [options]="typesOptions()"
          optionLabel="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '12px',
            },
          }"
        />
      </app-card-header>

      @if (store.isGroupsStatisticsLoading()) {
        <p-skeleton height="12.5rem" />
      } @else {
        <div class="flex flex-col">
          <app-donut-summary-chart
            [title]="chartLabel()"
            [currency]="store.selectedCurrencyCode()"
            [items]="displayedItems()"
            size="large"
            class="py-6 self-center"
          />

          <app-statistics-by-groups [groups]="displayedItems()" />
        </div>
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalyticStatisticsCard {
  private readonly datePipe = inject(DatePipe);
  protected readonly store = inject(AnalyticsStore);

  protected readonly typesOptions = signal([
    { name: 'Expenses' },
    { name: 'Income' },
    { name: 'Budget' },
  ]);

  protected readonly type = signal<{ name: string }>({ name: 'Expenses' });

  protected readonly chartLabel = computed(() => {
    const monthString = this.datePipe.transform(this.store.selectedMonth(), 'MM/yy');
    const typeName = this.type().name;
    const label =
      typeName === 'Income'
        ? 'Income for'
        : typeName === 'Expenses'
          ? 'Expenses for'
          : 'Budget for';
    return label + ' ' + monthString;
  });

  private readonly coloredIncomes = computed(() => {
    const items = this.store.incomeByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  private readonly coloredExpenses = computed(() => {
    const items = this.store.expenseByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  private readonly coloredBudgets = computed(() => {
    const items = this.store.budgetByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  protected readonly displayedItems = computed(() => {
    const typeName = this.type().name;
    if (typeName === 'Income') return this.coloredIncomes();
    if (typeName === 'Budget') return this.coloredBudgets();
    return this.coloredExpenses();
  });
}
```

---

## 6. Implementation Order

1. Append SQL function to `supabase/schemas/charts_funcs.sql`
2. Create `src/app/features/analytics/models/group-amount.ts`
3. Export from `src/app/features/analytics/models/index.ts`
4. Update `src/app/features/analytics/repositories/analytics-repository.ts`
5. Update `src/app/features/analytics/stores/analytics-store.ts`
6. Rewrite `src/app/features/analytics/ui/analytic-statistics-card/analytic-statistics-card.ts`

---

## 7. Verification

1. `pnpm test` — all unit tests pass (no new tests required for this integration; the store and repository follow patterns already covered by existing tests)
2. `pnpm lint` — no lint errors
3. Start the app (`pnpm start`) and navigate to the Analytics page:
   - Statistics card shows a skeleton while loading, then displays the donut chart
   - Switching between Expenses / Income / Budget updates the chart and legend immediately
   - Changing Month, Currency, or Accounts updates the Statistics card in sync with all other widgets
   - No data shown when there are no transactions for the selected filters
