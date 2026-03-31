# Plan: Create & Edit Budgets — DB Integration

## Context

The `create-budget` page and `CreateBudgetStore` are fully implemented at the UI level but operate entirely on hardcoded mock data. The goal is to replace all mock calls with real Supabase DB interactions, implement a proper edit mode for existing budgets, and add a conditional "Edit budget" button to the `total-budget` page. No UI components are to be removed or changed without cause.

---

## Architecture Flow

```
SQL migration → Model (DTO) → Mapper → Repository → Store → Component → Template
```

Each step is independently testable. Lint + tests run after every step.

---

## Steps

### Step 1 — SQL: `upsert_monthly_budgets`

**Schema file (source of truth):** `supabase/schemas/monthly_budgets_funcs.sql` — append the function at the end.

**Migration file (for deployment):** `supabase/migrations/20260330000001_add_upsert_monthly_budgets_func.sql` — same content, the user applies it manually when ready.

Реалізує стратегію **Merge**:
- Існуючі рядки (category_id збігається) → **UPDATE** `planned_amount`
- Нові рядки (category_id відсутній у БД) → **INSERT**
- Відсутні рядки (category_id є в БД, але відсутній у новому списку) → **DELETE**

Потребує унікального обмеження на `(user_id, budget_month, category_id, currency_id)`, яке наразі відсутнє. Міграція додає обмеження першим кроком.

```sql
-- Add unique constraint required for ON CONFLICT upsert
ALTER TABLE public.monthly_budgets
  ADD CONSTRAINT monthly_budgets_user_month_category_currency_key
  UNIQUE (user_id, budget_month, category_id, currency_id);

-- Merge strategy: UPDATE existing, INSERT new, DELETE missing
CREATE OR REPLACE FUNCTION public.upsert_monthly_budgets(
  p_month         date,
  p_currency_code text,
  p_categories    jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO ''
AS $$
DECLARE
  v_currency_id bigint;
  v_month_start date;
BEGIN
  SELECT id INTO v_currency_id
  FROM public.currencies
  WHERE code = p_currency_code
  LIMIT 1;

  IF v_currency_id IS NULL THEN
    RAISE EXCEPTION 'Currency not found: %', p_currency_code;
  END IF;

  v_month_start := date_trunc('month', p_month::timestamp)::date;

  -- DELETE: remove rows not present in the new list (or with planned_amount = 0)
  DELETE FROM public.monthly_budgets
  WHERE user_id     = auth.uid()
    AND budget_month = v_month_start
    AND currency_id  = v_currency_id
    AND category_id NOT IN (
      SELECT (item->>'category_id')::bigint
      FROM jsonb_array_elements(p_categories) AS item
      WHERE (item->>'planned_amount')::numeric > 0
    );

  -- INSERT new / UPDATE existing via ON CONFLICT
  INSERT INTO public.monthly_budgets (user_id, budget_month, category_id, currency_id, planned_amount)
  SELECT
    auth.uid(),
    v_month_start,
    (item->>'category_id')::bigint,
    v_currency_id,
    (item->>'planned_amount')::numeric
  FROM jsonb_array_elements(p_categories) AS item
  WHERE (item->>'planned_amount')::numeric > 0
  ON CONFLICT (user_id, budget_month, category_id, currency_id)
  DO UPDATE SET
    planned_amount = EXCLUDED.planned_amount;
  -- updated_at is updated automatically by the existing trigger
END;
$$;
```

> The user applies the migration manually after this step.

**Checkpoint:** Review SQL manually. No lint/test yet.

---

### Step 2 — Model: `MonthlyBudgetDetailedDto`

**New file:** `src/app/features/budget/models/monthly-budget-detailed.ts`

```typescript
export interface MonthlyBudgetDetailedDto {
  category_id: number;
  category_name: string;
  group_id: number;
  group_name: string;
  planned_amount: number;
  previous_planned_amount: number;
  spent_amount: number;
  previous_spent_amount: number;
  is_unplanned: boolean;
}
```

**Modify:** `src/app/features/budget/models/index.ts` — add `export * from './monthly-budget-detailed';`

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 3 — Mapper: `fromDetailedBudgetDtosToGroupRows`

**File:** `src/app/features/budget/mappers/budget-mapper.ts`

Add import:
```typescript
import { BudgetCategoryRow, BudgetGroupRow } from '../pages/create-budget/create-budget-store';
```

Add method:
```typescript
fromDetailedBudgetDtosToGroupRows(
  dtos: MonthlyBudgetDetailedDto[],
  mode: 'edit' | 'generate',
): BudgetGroupRow[] {
  let nextTempId = 1;
  const groupMap = new Map<number, { groupId: number; dtos: MonthlyBudgetDetailedDto[] }>();

  for (const dto of dtos) {
    if (!groupMap.has(dto.group_id)) {
      groupMap.set(dto.group_id, { groupId: dto.group_id, dtos: [] });
    }
    groupMap.get(dto.group_id)!.dtos.push(dto);
  }

  const result: BudgetGroupRow[] = [];

  for (const { groupId, dtos: groupDtos } of groupMap.values()) {
    const categories: BudgetCategoryRow[] = [];

    for (const dto of groupDtos) {
      if (mode === 'generate' && dto.previous_planned_amount <= 0 && dto.spent_amount <= 0) {
        continue;
      }
      categories.push({
        tempId: nextTempId++,
        categoryId: dto.category_id,
        plannedAmount: mode === 'edit' ? dto.planned_amount : dto.previous_planned_amount,
        prevPlannedAmount: dto.previous_planned_amount,
        currentSpentAmount: dto.spent_amount,
        prevSpentAmount: dto.previous_spent_amount,
      });
    }

    if (mode === 'generate' && categories.length === 0) continue;

    result.push({ tempId: nextTempId++, groupId, categories });
  }

  return result;
}
```

**Mapper logic:**
- `edit` mode: `plannedAmount = planned_amount` (current month budget)
- `generate` mode: `plannedAmount = previous_planned_amount`; only rows where `previous_planned_amount > 0 || spent_amount > 0` are included (categories with previous activity or current spending)
- Mapper-assigned `tempId` starts at 1; interactive additions use 1000+ (no collision)

**New file:** `src/app/features/budget/mappers/budget-mapper.spec.ts`

Write tests covering:
- `edit` mode includes all rows and uses `planned_amount`
- `generate` mode filters out rows with no previous activity
- `generate` mode includes rows with `spent_amount > 0` even if `previous_planned_amount = 0`
- `generate` mode uses `previous_planned_amount` as `plannedAmount`
- All `tempId` values are unique

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 4 — Repository: Two New Methods

**File:** `src/app/features/budget/repositories/budget-repository.ts`

Add import: `import { MonthlyBudgetDetailedDto } from '../models';`

Add methods:

```typescript
async getDetailedMonthlyBudgets({
  month,
  currencyCode,
}: {
  month: string;       // 'YYYY-MM-DD', pre-formatted by the caller
  currencyCode: string;
}): Promise<MonthlyBudgetDetailedDto[]> {
  const { data, error } = await this.supabase.client
    .rpc('get_monthly_budgets_detailed', {
      p_month: month,
      p_currency_code: currencyCode,
    })
    .select();

  if (error) throw new Error(error.message);
  return data as MonthlyBudgetDetailedDto[];
}

async upsertMonthlyBudgets({
  month,
  currencyCode,
  categories,
}: {
  month: string;
  currencyCode: string;
  categories: { category_id: number; planned_amount: number }[];
}): Promise<void> {
  const { error } = await this.supabase.client.rpc('upsert_monthly_budgets', {
    p_month: month,
    p_currency_code: currencyCode,
    p_categories: categories,
  });

  if (error) throw new Error(error.message);
}
```

**New file:** `src/app/features/budget/repositories/budget-repository.spec.ts`

Test error propagation for both methods and that `upsertMonthlyBudgets` resolves with an empty categories array.

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 5 — CreateBudgetStore: Wire Real DB Calls

**File:** `src/app/features/budget/pages/create-budget/create-budget-store.ts`

**State change:** Add `isLoading: boolean` (initial: `false`).

**Add imports:**
```typescript
import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { BudgetMapper } from '../../mappers';
import { BudgetRepository } from '../../repositories';
```

**Remove:** `import { MOCK_PREVIOUS_GROUPS } from './create-budget-mock-data';`

**Inject in `withMethods`:**
```typescript
withMethods((store, repository = inject(BudgetRepository), mapper = inject(BudgetMapper)) => {
```

**Replace `generateFromPreviousMonth`:**
```typescript
async generateFromPreviousMonth(month: string, currencyCode: string): Promise<Result> {
  patchState(store, { isGenerating: true });
  try {
    const dtos = await repository.getDetailedMonthlyBudgets({ month, currencyCode });
    const groups = mapper.fromDetailedBudgetDtosToGroupRows(dtos, 'generate');
    patchState(store, { groups, budgetExists: true, isGenerating: false });
    return resultOk();
  } catch (error) {
    patchState(store, { isGenerating: false });
    return resultError(error);
  }
},
```

**Add `loadExistingBudget`:**
```typescript
async loadExistingBudget(month: string, currencyCode: string): Promise<Result> {
  patchState(store, { isLoading: true });
  try {
    const dtos = await repository.getDetailedMonthlyBudgets({ month, currencyCode });
    const hasBudget = dtos.some((d) => d.planned_amount > 0);
    if (hasBudget) {
      const groups = mapper.fromDetailedBudgetDtosToGroupRows(dtos, 'edit');
      patchState(store, { groups, budgetExists: true, isLoading: false });
    } else {
      patchState(store, { isLoading: false });
    }
    return resultOk();
  } catch (error) {
    patchState(store, { isLoading: false });
    return resultError(error);
  }
},
```

**Replace `saveBudget`:**
```typescript
async saveBudget(month: string, currencyCode: string): Promise<Result> {
  patchState(store, { isSaving: true });
  const categories = store.groups().flatMap((g) =>
    g.categories.map((c) => ({ category_id: c.categoryId, planned_amount: c.plannedAmount })),
  );
  try {
    await repository.upsertMonthlyBudgets({ month, currencyCode, categories });
    patchState(store, { isSaving: false });
    return resultOk();
  } catch (error) {
    patchState(store, { isSaving: false });
    return resultError(error);
  }
},
```

All other methods (`startManual`, `addGroup`, `removeGroup`, `addCategory`, `removeCategory`, `updateCategoryPlanned`) remain unchanged.

**New file:** `src/app/features/budget/pages/create-budget/create-budget-store.spec.ts`

Test cases:
- `loadExistingBudget`: sets `budgetExists=true` when rows with `planned_amount > 0` exist
- `loadExistingBudget`: leaves `budgetExists=false` when no planned rows
- `loadExistingBudget`: returns `resultError` on repository failure
- `generateFromPreviousMonth`: populates groups via mapper `'generate'` mode
- `saveBudget`: calls `upsertMonthlyBudgets` with flattened categories
- `saveBudget`: returns `resultError` on failure

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 6 — CreateBudget Component: Init Load + Post-Save Navigation

**File:** `src/app/features/budget/pages/create-budget/create-budget.ts`

**Add imports:** `import { MessageService } from 'primeng/api';` and `import { ToastModule } from 'primeng/toast';`

**Add injection:** `private readonly messageService = inject(MessageService);`

**Add `ToastModule`** to the component's `imports` array and `MessageService` to `providers`.

**Add `<p-toast />`** at the top of the template.

**Constructor:** Call `loadExistingBudget` on init (after categories load guard):
```typescript
constructor() {
  if (!this.categoriesStore.isLoaded()) {
    this.categoriesStore.loadAll();
  }
  if (this.budgetStore.currencyCode()) {
    this.store.loadExistingBudget(this.monthIso(), this.currencyCode());
  }
}
```

**Update `onGenerateFromPrevious`:**
```typescript
protected async onGenerateFromPrevious(): Promise<void> {
  const result = await this.store.generateFromPreviousMonth(
    this.monthIso(),
    this.currencyCode(),
  );
  if (result.ok) {
    setTimeout(() => this.groupList()?.expandAll(), 100);
  }
}
```

**Update `onSave`:**
```typescript
protected async onSave(): Promise<void> {
  const result = await this.store.saveBudget(this.monthIso(), this.currencyCode());
  if (result.ok) {
    this.messageService.add({ severity: 'success', summary: 'Budget saved' });
  } else {
    this.messageService.add({ severity: 'error', summary: 'Failed to save budget' });
  }
}
```

Inject `MessageService` from PrimeNG (`import { MessageService } from 'primeng/api'`) and add `ToastModule` to the component imports. The `<p-toast />` element must be present in the template (add once at the top of the template).

**Template:** Add `isLoading` guard wrapping the existing `@if (store.budgetExists())` block:
```html
@if (store.isLoading()) {
  <div class="flex justify-center py-12">
    <i class="pi pi-spin pi-spinner text-2xl text-surface-400"></i>
  </div>
} @else if (store.budgetExists()) {
  <!-- existing budget-exists block -->
} @else {
  <!-- existing empty-state block -->
}
```

**Update** `src/app/features/budget/pages/create-budget/create-budget.spec.ts` to reflect the new async method signatures and Router injection.

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 7 — TotalBudget: Conditional Edit/Create Button

**File:** `src/app/features/budget/pages/total-budget/total-budget.html`

Replace the single static `p-button` with a conditional:

```html
@if (totalBudgetStore.monthlyBudgets().length > 0) {
  <p-button
    class="shrink-0 self-end sm:self-auto"
    icon="pi pi-pencil"
    label="Edit budget"
    [rounded]="true"
    size="large"
    (onClick)="gotoCreateBudget()"
    [dt]="{ root: { lg: { fontSize: '14px' } } }"
  />
} @else {
  <p-button
    class="shrink-0 self-end sm:self-auto"
    icon="pi pi-plus"
    label="Add new budget"
    [rounded]="true"
    size="large"
    (onClick)="gotoCreateBudget()"
    [dt]="{ root: { lg: { fontSize: '14px' } } }"
  />
}
```

No TypeScript changes needed — `gotoCreateBudget()` navigates to `/budget/create` in both cases. The `CreateBudget` component auto-detects the existing budget via `loadExistingBudget`.

**Checkpoint:** `pnpm lint && pnpm test`

---

### Step 8 — Delete Mock Data File

**Delete:** `src/app/features/budget/pages/create-budget/create-budget-mock-data.ts`

After confirming Step 5 is lint-clean and the import is removed from the store.

**Checkpoint:** `pnpm lint && pnpm test` (full suite)

---

## Critical Files

| File | Change Type |
|------|-------------|
| `supabase/schemas/monthly_budgets_funcs.sql` | Modify (append function) |
| `supabase/migrations/20260330000001_add_upsert_monthly_budgets_func.sql` | New (user applies manually) |
| `src/app/features/budget/models/monthly-budget-detailed.ts` | New |
| `src/app/features/budget/models/index.ts` | Modify (re-export) |
| `src/app/features/budget/mappers/budget-mapper.ts` | Modify (add method) |
| `src/app/features/budget/mappers/budget-mapper.spec.ts` | New |
| `src/app/features/budget/repositories/budget-repository.ts` | Modify (add 2 methods) |
| `src/app/features/budget/repositories/budget-repository.spec.ts` | New |
| `src/app/features/budget/pages/create-budget/create-budget-store.ts` | Modify (wire real calls) |
| `src/app/features/budget/pages/create-budget/create-budget-store.spec.ts` | New |
| `src/app/features/budget/pages/create-budget/create-budget.ts` | Modify (init + async) |
| `src/app/features/budget/pages/create-budget/create-budget.spec.ts` | Modify (update tests) |
| `src/app/features/budget/pages/total-budget/total-budget.html` | Modify (conditional button) |
| `src/app/features/budget/pages/create-budget/create-budget-mock-data.ts` | Delete |

---

## Reused Functions / Utilities

- `resultOk()` / `resultError()` — `src/app/core/utils/result-factory.ts`
- `Result` type — `src/app/core/models/result.ts`
- `dayjs` — date formatting (already used in the component via `monthIso` computed)
- `BudgetRepository.getDetailedMonthlyBudgets` — calls existing `get_monthly_budgets_detailed` RPC
- `BudgetStore.currencyCode()` / `BudgetStore.month()` — already injected in the component

---

## Gotchas

1. **`currencyCode` null on init:** `BudgetStore.currencyCode()` starts as `null`. Guard `loadExistingBudget` with `if (this.budgetStore.currencyCode())` to avoid firing with a null currency.

2. **`tempId` ranges:** Mapper assigns IDs from 1 upward; store's interactive additions use 1000+. No collision for realistic data sizes, but note this dependency if the ranges ever need to change.

3. **`generate` includes unplanned categories:** Categories with `spent_amount > 0` but `previous_planned_amount = 0` will be included in "generate" mode (current month spending without a prior budget). This is the intended behavior per spec.

---

## Verification

1. Log in as `demo@mail.com` / `password1234`
2. Navigate to `/budget` for **February 2026** (has seeded budget data)
   - Top button shows **"Edit budget"** with pencil icon
   - Click → navigates to `/budget/create`
   - Existing budgets load automatically in edit mode (groups + amounts populated)
   - Modify a planned amount → click **"Save"** → success toast appears → data persists in DB
3. Navigate to `/budget` for **March 2026** (no seeded budget)
   - Top button shows **"Add new budget"** with plus icon (or empty state CTA)
   - Click → navigates to `/budget/create` → shows empty state (generate / manual)
   - Click **"Generate"** → previous month's budgets + current spending load into the editor
   - Click **"Create manually"** → empty group list, add groups/categories manually
   - Save in either mode → success toast appears → data persists in DB
