import { inject } from '@angular/core';
import { Group } from '@core/models/categories';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import { BudgetRepository } from '../repositories';

interface BudgetState {
  month: Date;
  currencyCode: string | null;
  isGroupLoading: boolean;
  isGroupError: boolean;
  selectedGroup: Group | null;
}

const initialState: BudgetState = {
  month: new Date(),
  currencyCode: null,
  isGroupLoading: false,
  isGroupError: false,
  selectedGroup: null,
};

export const BudgetStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    selectedGroupName: () => store.selectedGroup()?.name || '',
  })),

  withMethods((store, repository = inject(BudgetRepository)) => ({
    async loadGroup(groupId: number): Promise<Result> {
      patchState(store, { isGroupLoading: true });

      try {
        const group = await repository.getGroup(groupId);

        patchState(store, {
          isGroupLoading: false,
          selectedGroup: group,
        });

        return resultOk();
      } catch (error) {
        patchState(store, {
          isGroupError: true,
        });

        return resultError(error);
      }
    },

    updateMonth(month: Date) {
      patchState(store, () => ({
        month,
      }));
    },

    updateCurrencyCode(currencyCode: string) {
      patchState(store, () => ({
        currencyCode,
      }));
    },

    resetSelectedGroup() {
      patchState(store, () => ({
        selectedGroup: null,
      }));
    },
  })),
);
