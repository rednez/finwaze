import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import {
  BudgetStatus,
  CategoryMonthlyBudget,
  MonthlyBudgetTotals,
  MonthlyExpense,
} from '../models';
import { BudgetRepository } from '../repositories';
import { getBudgetStatus } from '../utils';
import { BudgetStore } from './budget-store';

interface BudgetsByGroupState {
  isMonthlyBudgetsLoading: boolean;
  isMonthlyBudgetsUpdating: boolean;
  isMonthlyBudgetsLoaded: boolean;
  isMonthlyBudgetsError: boolean;

  isMonthlyBudgetTotalsLoading: boolean;
  isMonthlyBudgetTotalsUpdating: boolean;
  isMonthlyBudgetTotalsLoaded: boolean;
  isMonthlyBudgetTotalsError: boolean;

  isMonthlyExpensesLoading: boolean;
  isMonthlyExpensesUpdating: boolean;
  isMonthlyExpensesLoaded: boolean;
  isMonthlyExpensesError: boolean;

  monthlyBudgets: CategoryMonthlyBudget[];
  status: 'all' | BudgetStatus;
  selectedCategoriesIds: number[];
  monthlyBudgetTotals: MonthlyBudgetTotals;
  monthlyExpenses: MonthlyExpense[];
}

const initialState: BudgetsByGroupState = {
  isMonthlyBudgetsLoading: false,
  isMonthlyBudgetsUpdating: false,
  isMonthlyBudgetsLoaded: false,
  isMonthlyBudgetsError: false,

  isMonthlyBudgetTotalsLoading: false,
  isMonthlyBudgetTotalsUpdating: false,
  isMonthlyBudgetTotalsLoaded: false,
  isMonthlyBudgetTotalsError: false,

  isMonthlyExpensesLoading: false,
  isMonthlyExpensesUpdating: false,
  isMonthlyExpensesLoaded: false,
  isMonthlyExpensesError: false,

  monthlyBudgets: [],
  status: 'all',
  selectedCategoriesIds: [],
  monthlyBudgetTotals: {
    plannedAmount: 0,
    spentAmount: 0,
  },
  monthlyExpenses: [],
};

export const BudgetsByGroupStore = signalStore(
  withState(initialState),

  withComputed((store) => ({
    _budgetsWithStatus: () =>
      store.monthlyBudgets().map((i) => ({
        ...i,
        status: getBudgetStatus(i.plannedAmount, i.spentAmount),
      })),
  })),

  withComputed((store) => ({
    filteredBudgets: () => {
      if (store.status() === 'all') {
        return store
          ._budgetsWithStatus()
          .filter(
            (i) =>
              store.selectedCategoriesIds().length === 0 ||
              store.selectedCategoriesIds().includes(i.id),
          );
      } else {
        return store
          ._budgetsWithStatus()
          .filter((i) => i.status === store.status())
          .filter(
            (i) =>
              store.selectedCategoriesIds().length === 0 ||
              store.selectedCategoriesIds().includes(i.id),
          );
      }
    },
  })),

  withMethods(
    (
      store,
      repository = inject(BudgetRepository),
      budgetStore = inject(BudgetStore),
    ) => ({
      async loadMonthlyBudgets(): Promise<Result> {
        if (store.isMonthlyBudgetsLoaded()) {
          patchState(store, { isMonthlyBudgetsUpdating: true });
        } else {
          patchState(store, { isMonthlyBudgetsLoading: true });
        }
        patchState(store, { isMonthlyBudgetsError: false });

        try {
          if (!budgetStore.currencyCode()) {
            throw new Error('Currency code is required');
          }
          if (!budgetStore.selectedGroup()) {
            throw new Error('Current group is required');
          }

          const data = await repository.getCategoriesMonthlyBudgets({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
            groupId: budgetStore.selectedGroup()!.id,
          });

          patchState(store, {
            isMonthlyBudgetsLoading: false,
            isMonthlyBudgetsUpdating: false,
            isMonthlyBudgetsLoaded: true,
            monthlyBudgets: data,
          });

          return resultOk();
        } catch (error) {
          patchState(store, {
            isMonthlyBudgetsLoading: false,
            isMonthlyBudgetsUpdating: false,
            isMonthlyBudgetsError: true,
          });

          return resultError(error);
        }
      },

      async loadMonthlyBudgetTotals(): Promise<Result> {
        if (store.isMonthlyBudgetTotalsLoaded()) {
          patchState(store, { isMonthlyBudgetTotalsUpdating: true });
        } else {
          patchState(store, { isMonthlyBudgetTotalsLoading: true });
        }
        patchState(store, { isMonthlyBudgetTotalsError: false });

        try {
          if (!budgetStore.currencyCode()) {
            throw new Error('Currency code is required');
          }
          if (!budgetStore.selectedGroup()) {
            throw new Error('Current group is required');
          }

          const data = await repository.getMonthlyBudgetTotalsByGroup({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
            groupId: budgetStore.selectedGroup()!.id,
          });

          patchState(store, {
            isMonthlyBudgetTotalsLoading: false,
            isMonthlyBudgetTotalsUpdating: false,
            isMonthlyBudgetTotalsLoaded: true,
            monthlyBudgetTotals: data,
          });

          return resultOk();
        } catch (error) {
          patchState(store, {
            isMonthlyBudgetTotalsLoading: false,
            isMonthlyBudgetTotalsUpdating: false,
            isMonthlyBudgetTotalsError: true,
          });

          return resultError(error);
        }
      },

      async loadMonthlyExpenses(): Promise<Result> {
        if (store.isMonthlyExpensesLoaded()) {
          patchState(store, { isMonthlyExpensesUpdating: true });
        } else {
          patchState(store, { isMonthlyExpensesLoading: true });
        }
        patchState(store, { isMonthlyExpensesError: false });

        try {
          if (!budgetStore.currencyCode()) {
            throw new Error('Currency code is required');
          }
          if (!budgetStore.selectedGroup()) {
            throw new Error('Current group is required');
          }

          const data = await repository.getMonthlyExpensesByCategories({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
            groupId: budgetStore.selectedGroup()!.id,
          });

          patchState(store, {
            isMonthlyExpensesLoading: false,
            isMonthlyExpensesUpdating: false,
            isMonthlyExpensesLoaded: true,
            monthlyExpenses: data,
          });

          return resultOk();
        } catch (error) {
          patchState(store, {
            isMonthlyExpensesLoading: false,
            isMonthlyExpensesUpdating: false,
            isMonthlyExpensesError: true,
          });

          return resultError(error);
        }
      },

      updateStatus(status: 'all' | BudgetStatus) {
        patchState(store, () => ({ status }));
      },

      updateSelectedCategoriesIds(ids: number[]) {
        patchState(store, () => ({ selectedCategoriesIds: ids }));
      },
    }),
  ),
);
