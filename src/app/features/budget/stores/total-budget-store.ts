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
  GroupMonthlyBudget,
  MonthlyBudgetTotals,
  MonthlyExpense,
} from '../models';
import { BudgetRepository } from '../repositories';
import { getBudgetStatus } from '../utils';
import { BudgetStore } from './budget-store';

interface TotalBudgetState {
  isGroupsMonthlyBudgetsLoading: boolean;
  isGroupsMonthlyBudgetsUpdating: boolean;
  isGroupsMonthlyBudgetsLoaded: boolean;
  isGroupsMonthlyBudgetsError: boolean;

  isMonthlyBudgetTotalsLoading: boolean;
  isMonthlyBudgetTotalsUpdating: boolean;
  isMonthlyBudgetTotalsLoaded: boolean;
  isMonthlyBudgetTotalsError: boolean;

  isMonthlyExpensesLoading: boolean;
  isMonthlyExpensesUpdating: boolean;
  isMonthlyExpensesLoaded: boolean;
  isMonthlyExpensesError: boolean;

  groupsMonthlyBudgets: GroupMonthlyBudget[];
  status: 'all' | BudgetStatus;
  selectedGroupsIds: number[];
  monthlyBudgetTotals: MonthlyBudgetTotals;
  monthlyExpenses: MonthlyExpense[];
}

const initialState: TotalBudgetState = {
  isGroupsMonthlyBudgetsLoading: false,
  isGroupsMonthlyBudgetsUpdating: false,
  isGroupsMonthlyBudgetsLoaded: false,
  isGroupsMonthlyBudgetsError: false,

  isMonthlyBudgetTotalsLoading: false,
  isMonthlyBudgetTotalsUpdating: false,
  isMonthlyBudgetTotalsLoaded: false,
  isMonthlyBudgetTotalsError: false,

  isMonthlyExpensesLoading: false,
  isMonthlyExpensesUpdating: false,
  isMonthlyExpensesLoaded: false,
  isMonthlyExpensesError: false,

  groupsMonthlyBudgets: [],
  status: 'all',
  selectedGroupsIds: [],
  monthlyBudgetTotals: {
    plannedAmount: 0,
    spentAmount: 0,
  },
  monthlyExpenses: [],
};

export const TotalBudgetStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    _budgetsWithStatus: () =>
      store.groupsMonthlyBudgets().map((i) => ({
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
              store.selectedGroupsIds().length === 0 ||
              store.selectedGroupsIds().includes(i.id),
          );
      } else {
        return store
          ._budgetsWithStatus()
          .filter((i) => i.status === store.status())
          .filter(
            (i) =>
              store.selectedGroupsIds().length === 0 ||
              store.selectedGroupsIds().includes(i.id),
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
      async loadGroupsMonthlyBudgets(): Promise<Result> {
        if (store.isGroupsMonthlyBudgetsLoaded()) {
          patchState(store, { isGroupsMonthlyBudgetsUpdating: true });
        } else {
          patchState(store, { isGroupsMonthlyBudgetsLoading: true });
        }
        patchState(store, { isGroupsMonthlyBudgetsError: false });

        try {
          if (!budgetStore.currencyCode()) {
            throw new Error('Currency code is required');
          }

          const data = await repository.getGroupsMonthlyBudgets({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
          });

          patchState(store, {
            isGroupsMonthlyBudgetsLoading: false,
            isGroupsMonthlyBudgetsUpdating: false,
            isGroupsMonthlyBudgetsLoaded: true,
            groupsMonthlyBudgets: data,
          });

          return resultOk();
        } catch (error) {
          patchState(store, {
            isGroupsMonthlyBudgetsLoading: false,
            isGroupsMonthlyBudgetsUpdating: false,
            isGroupsMonthlyBudgetsError: true,
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

          const data = await repository.getMonthlyBudgetTotals({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
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

          const data = await repository.getMonthlyExpensesByGroup({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
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

      updateSelectedGroupsIds(ids: number[]) {
        patchState(store, () => ({ selectedGroupsIds: ids }));
      },
    }),
  ),
);
