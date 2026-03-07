import { computed, inject } from '@angular/core';
import { Category, Group } from '@core/models/categories';
import { CategoriesRepository } from '@core/repositories/categories-repository';
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
  isError: boolean;
  allCategories: Category[];
}

const initialState: CategoriesState = {
  isLoading: false,
  isLoaded: false,
  isError: false,
  allCategories: [],
};

export const CategoriesStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    allGroups: computed(() => {
      const uniqueGroups = new Map<number, Group>();
      for (const category of store.allCategories()) {
        uniqueGroups.set(category.group.id, {
          id: category.group.id,
          name: category.group.name,
          transactionType: category.group.transactionType,
        });
      }
      return Array.from(uniqueGroups.values());
    }),
  })),

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
        const categories = await repository.getCategories();

        patchState(store, () => ({
          isLoading: false,
          isLoaded: true,
          isError: false,
          allCategories: categories,
        }));
      } catch (error) {
        patchState(store, () => ({
          isLoading: false,
          isError: true,
        }));
      }
    },
  })),
);
