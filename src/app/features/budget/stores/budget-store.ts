import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

interface BudgetState {
  month: Date;
  currencyCode: string | null;
  selectedGroupName: string | null;

  // TODO: ?
  // status: string | null;
  // groups: string | null;
}

const initialState: BudgetState = {
  month: new Date(),
  currencyCode: null,

  // TODO
  selectedGroupName: 'TODO',
};

export const BudgetStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store) => ({
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
  })),
);
