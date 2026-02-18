import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { waitFormMs } from '@shared/utils/wait-for-ms';

interface State {
  isTotalsSummaryLoading: boolean;
  isTotalsSummaryError: boolean;
  isCashFlowLoading: boolean;
  isCashFlowError: boolean;
  isRecentTransactionsLoading: boolean;
  isRecentTransactionsError: boolean;
}

const State: State = {
  isTotalsSummaryLoading: false,
  isCashFlowLoading: false,
  isCashFlowError: false,
  isTotalsSummaryError: false,
  isRecentTransactionsLoading: false,
  isRecentTransactionsError: false,
};

export const DashboardLoadingStateStore = signalStore(
  { providedIn: 'root' },
  withState(State),

  withMethods((store) => ({
    startTotalsSummaryLoading(): void {
      patchState(store, () => ({
        isTotalsSummaryLoading: true,
        isTotalsSummaryError: false,
      }));
    },

    async successTotalsSummaryLoading(): Promise<void> {
      await waitFormMs();
      patchState(store, () => ({
        isTotalsSummaryLoading: false,
      }));
    },

    errorTotalsSummaryLoading(): void {
      patchState(store, () => ({
        isTotalsSummaryLoading: false,
        isTotalsSummaryError: true,
      }));
    },

    startCashFlowLoading(): void {
      patchState(store, () => ({
        isCashFlowLoading: true,
        isCashFlowError: false,
      }));
    },

    async successCashFlowLoading(): Promise<void> {
      await waitFormMs();
      patchState(store, () => ({
        isCashFlowLoading: false,
      }));
    },

    errorCashFlowLoading(): void {
      patchState(store, () => ({
        isCashFlowLoading: false,
        isCashFlowError: true,
      }));
    },

    startRecentTransactionsLoading(): void {
      patchState(store, () => ({
        isRecentTransactionsLoading: true,
        isRecentTransactionsError: false,
      }));
    },

    async successRecentTransactionsLoading(): Promise<void> {
      await waitFormMs();
      patchState(store, () => ({
        isRecentTransactionsLoading: false,
      }));
    },

    errorRecentTransactionsLoading(): void {
      patchState(store, () => ({
        isRecentTransactionsLoading: false,
        isRecentTransactionsError: true,
      }));
    },
  })),
);
