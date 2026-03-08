import { computed, inject } from '@angular/core';
import { Category, Group } from '@core/models/categories';
import { Result } from '@core/models/result';
import { TransactionType } from '@core/models/transactions';
import { CategoriesRepository } from '@core/repositories/categories-repository';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';

export interface CategoriesState {
  isLoading: boolean;
  isLoaded: boolean;
  isCreating: boolean;
  isError: boolean;
  allGroups: Group[];
  allCategories: Category[];
}

const initialState: CategoriesState = {
  isLoading: false,
  isLoaded: false,
  isCreating: false,
  isError: false,
  allGroups: [],
  allCategories: [],
};

export const CategoriesStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    expensesGroups: computed(() =>
      store.allGroups().filter((i) => i.transactionType === 'expense'),
    ),
    incomeGroups: computed(() =>
      store.allGroups().filter((i) => i.transactionType === 'income'),
    ),
  })),

  withMethods((store, repository = inject(CategoriesRepository)) => ({
    async loadAll(): Promise<void> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const [groups, categories] = await Promise.all([
          repository.getGroups(),
          repository.getCategories(),
        ]);

        patchState(store, () => ({
          isLoading: false,
          isLoaded: true,
          isError: false,
          allGroups: groups,
          allCategories: categories,
        }));
      } catch (error) {
        patchState(store, () => ({
          isLoading: false,
          isError: true,
        }));
      }
    },

    async createGroup(
      name: string,
      transactionType: TransactionType,
    ): Promise<Result> {
      patchState(store, () => ({
        isCreating: true,
      }));

      try {
        const group = await repository.createGroup(name, transactionType);

        patchState(store, (state) => ({
          isCreating: false,
          allGroups: [...state.allGroups, group],
        }));

        return resultOk();
      } catch (error: any) {
        patchState(store, () => ({
          isCreating: false,
        }));

        return resultError(error);
      }
    },

    async createCategory(name: string, groupId: number): Promise<Result> {
      patchState(store, () => ({
        isCreating: true,
      }));

      try {
        const category = await repository.createCategory(name, groupId);

        patchState(store, (state) => ({
          isCreating: false,
          allCategories: [...state.allCategories, category],
        }));

        return resultOk();
      } catch (error: any) {
        patchState(store, () => ({
          isCreating: false,
        }));

        return resultError(error);
      }
    },
  })),
);
