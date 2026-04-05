import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { TransactionType } from '@core/models/transactions';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import { GroupWithCategories } from '../models';
import { GroupsAndCategoriesRepository } from '../repositories';

export interface GroupsAndCategoriesState {
  isLoading: boolean;
  isError: boolean;
  groups: GroupWithCategories[];
  hasGroups: boolean;
  filters: {
    transactionType: TransactionType | null;
  };
}

const initialState: GroupsAndCategoriesState = {
  isLoading: false,
  isError: false,
  groups: [],
  hasGroups: false,
  filters: {
    transactionType: null,
  },
};

export const GroupsAndCategoriesStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    filteredGroups: () =>
      store.filters().transactionType
        ? store
            .groups()
            .filter(
              (i) => i.transactionType === store.filters().transactionType,
            )
        : store.groups(),
  })),

  withMethods((store, repository = inject(GroupsAndCategoriesRepository)) => ({
    async loadGroups(): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const groups = await repository.getGroups();

        patchState(store, () => ({
          isLoading: false,
          groups,
          hasGroups: groups.length > 0,
        }));

        return resultOk();
      } catch (error) {
        patchState(store, () => ({
          ...initialState,
          isError: true,
        }));

        return resultError(error);
      }
    },

    async createGroup(
      name: string,
      transactionType: TransactionType,
    ): Promise<Result> {
      try {
        const group = await repository.createGroup(name, transactionType);

        patchState(store, (state) => ({
          groups: [
            {
              ...group,
              categories: [],
            },
            ...state.groups,
          ],
          hasGroups: true,
        }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    async renameGroup(id: number, name: string): Promise<Result> {
      try {
        await repository.renameGroup(id, name);

        const groups = store.groups();
        const groupIndex = groups.findIndex((g) => g.id === id);
        if (groupIndex === -1) {
          throw new Error('Group not found');
        }
        groups[groupIndex].name = name;

        patchState(store, () => ({ groups }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    async deleteGroup(id: number): Promise<Result> {
      try {
        const { hasGroups } = await repository.deleteGroup(id);

        patchState(store, (state) => ({
          groups: state.groups.filter((g) => g.id !== id),
          hasGroups,
        }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    async createCategory(name: string, groupId: number): Promise<Result> {
      try {
        const category = await repository.createCategory(name, groupId);

        const groups = store.groups();
        const groupIndex = groups.findIndex((g) => g.id === groupId);
        if (groupIndex === -1) {
          throw new Error('Group not found');
        }
        groups[groupIndex].categories.push({
          ...category,
          transactionsCount: 0,
        });

        patchState(store, () => ({ groups }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    async renameCategory(params: {
      categoryId: number;
      groupId: number;
      name: string;
    }): Promise<Result> {
      try {
        await repository.renameCategory(params.categoryId, params.name);

        const groups = store.groups();
        const groupIndex = groups.findIndex((g) => g.id === params.groupId);
        if (groupIndex === -1) {
          throw new Error('Group not found');
        }
        const categoryIndex = groups[groupIndex].categories.findIndex(
          (c) => c.id === params.categoryId,
        );
        if (categoryIndex === -1) {
          throw new Error('Category not found');
        }
        groups[groupIndex].categories[categoryIndex].name = params.name;

        patchState(store, () => ({ groups }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    async deleteCategory(categoryId: number, groupId: number): Promise<Result> {
      try {
        await repository.deleteCategory(categoryId);

        const groups = store.groups();
        const groupIndex = groups.findIndex((g) => g.id === groupId);
        if (groupIndex === -1) {
          throw new Error('Group not found');
        }
        groups[groupIndex].categories = groups[groupIndex].categories.filter(
          (c) => c.id !== categoryId,
        );

        patchState(store, () => ({ groups }));

        return resultOk();
      } catch (error) {
        return resultError(error);
      }
    },

    updateTransactionType(value: TransactionType | null) {
      patchState(store, () => ({
        filters: { transactionType: value },
      }));
    },
  })),
);
