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
import { BudgetStatus, GroupMonthlyBudget } from '../models';
import { BudgetRepository } from '../repositories';
import { getBudgetStatus } from '../utils';
import { BudgetStore } from './budget-store';

interface TotalBudgetState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  groupsMonthlyBudgets: GroupMonthlyBudget[];
  status: 'all' | BudgetStatus;
  selectedGroupsIds: number[];
}

const initialState: TotalBudgetState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  groupsMonthlyBudgets: [],
  status: 'all',
  selectedGroupsIds: [],
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
        if (store.isLoaded()) {
          patchState(store, () => ({
            isUpdating: true,
          }));
        } else {
          patchState(store, () => ({
            isLoading: true,
          }));
        }

        try {
          if (!budgetStore.currencyCode()) {
            throw new Error('Currency code is required');
          }

          const data = await repository.getGroupsMonthlyBudgets({
            month: budgetStore.month(),
            currencyCode: budgetStore.currencyCode()!,
          });

          if (store.isLoaded()) {
            patchState(store, () => ({
              isUpdating: false,
              groupsMonthlyBudgets: data,
            }));
          } else {
            patchState(store, () => ({
              isLoading: false,
              isLoaded: true,
              groupsMonthlyBudgets: data,
            }));
          }

          return resultOk();
        } catch (error) {
          patchState(store, () => ({
            ...initialState,
            isError: true,
          }));

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
