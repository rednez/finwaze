import { SavingsGoal } from '@core/models/savings-goal';
import { signalStore, withState } from '@ngrx/signals';

interface GoalsListState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  goals: SavingsGoal[];
}

const initialState: GoalsListState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  goals: [],
};

export const GoalsListStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
);
