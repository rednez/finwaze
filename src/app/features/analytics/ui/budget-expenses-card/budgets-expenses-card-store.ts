import { computed, effect, inject, untracked } from '@angular/core';
import {
  patchState,
  signalStore,
  withComputed,
  withHooks,
  withMethods,
  withState,
} from '@ngrx/signals';
import { MonthlyBudgetExpense } from '../../models';
import { AnalyticsRepository } from '../../repositories';
import { AnalyticsStore } from '../../stores';

interface BudgetsExpensesState {
  yearlyData: MonthlyBudgetExpense[];
  selectedYear: Date;
}

export const BudgetsExpensesCardStore = signalStore(
  withState<BudgetsExpensesState>({
    yearlyData: [],
    selectedYear: new Date(),
  }),

  withMethods((store, repository = inject(AnalyticsRepository)) => ({
    async load(currencyCode: string): Promise<void> {
      if (!currencyCode) return;
      const data = await repository.getYearlyBudgetsVsExpenses(
        store.selectedYear().getFullYear(),
        currencyCode,
      );
      patchState(store, { yearlyData: data });
    },

    updateYear: (year: Date) => patchState(store, { selectedYear: year }),
  })),

  withComputed((store) => ({
    labels: computed(() => store.yearlyData().map((d) => d.month)),
    expenses: computed(() => store.yearlyData().map((d) => d.expenseAmount)),
    budgets: computed(() => store.yearlyData().map((d) => d.budgetAmount)),
  })),

  withHooks({
    onInit(store) {
      const analyticsStore = inject(AnalyticsStore);
      effect(() => {
        store.selectedYear();
        const currencyCode = analyticsStore.selectedCurrencyCode();
        untracked(() => store.load(currencyCode));
      });
    },
  }),
);
