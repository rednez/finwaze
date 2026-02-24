import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { waitFormMs } from '@shared/utils/wait-for-ms';

interface State {
  isLoading: boolean;
  isLoaded: boolean;
  isUpdating: boolean;
  isError: boolean;
}

const State: State = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
};

export const DashboardLoadingStateStore = signalStore(
  { providedIn: 'root' },
  withState(State),

  withMethods((store) => ({
    startLoading(): void {
      patchState(store, () => ({
        isLoading: true,
        isLoaded: false,
        isError: false,
      }));
    },
    async successLoading(): Promise<void> {
      await waitFormMs();
      patchState(store, () => ({
        isLoading: false,
        isLoaded: true,
      }));
    },
    errorLoading(): void {
      patchState(store, () => ({
        isLoading: false,
        isError: true,
      }));
    },
    startUpdating(): void {
      patchState(store, () => ({
        isUpdating: true,
        isError: false,
      }));
    },
    async successUpdating(): Promise<void> {
      await waitFormMs();
      patchState(store, () => ({
        isUpdating: false,
      }));
    },
    errorUpdating(): void {
      patchState(store, () => ({
        isUpdating: false,
        isError: true,
      }));
    },
  })),
);
