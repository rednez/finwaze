import { inject } from '@angular/core';
import { AuthRepository } from '@core/repositories/auth-repository';
import { DemoModeService } from '@core/services/demo-mode/demo-mode.service';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';

export interface AuthState {
  isInitializing: boolean;
  user: {
    id: string;
    email: string;
    name: string;
    imgUrl: string;
  } | null;
}

const initialState: AuthState = {
  isInitializing: false,
  user: null,
};

export const AuthStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    isAuthorized: () => !!store.user(),
  })),

  withMethods((
    store,
    authRepository = inject(AuthRepository),
    demoModeService = inject(DemoModeService),
  ) => ({
    async init(): Promise<void> {
      if (store.isAuthorized()) {
        return;
      }

      patchState(store, () => ({
        isInitializing: true,
      }));

      try {
        const user = await authRepository.getUser();
        patchState(store, () => ({
          isInitializing: false,
          user,
        }));
      } catch {
        patchState(store, () => ({
          isInitializing: false,
        }));
      }
    },

    async loginWithGoogle() {
      await authRepository.loginWithGoogle();
      const user = await authRepository.getUser();

      patchState(store, () => ({
        user,
      }));
    },

    async loginWithDemo() {
      await authRepository.loginWithDemo();
      const user = await authRepository.getUser();
      demoModeService.enable();

      patchState(store, () => ({
        user,
      }));
    },

    async logOut() {
      await authRepository.logOut();
      demoModeService.disable();

      patchState(store, () => ({
        user: null,
      }));
    },
  })),
);
