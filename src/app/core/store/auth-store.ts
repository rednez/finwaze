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
    provider: string;
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

  withMethods(
    (
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
          errorCode: null,
        }));
      },

      async signUp(credits: { email: string; password: string }) {
        const { error } = await authRepository.signUp(credits);

        if (error) {
          return { success: false, error: error.message };
        } else {
          return { success: true, error: null };
        }
      },

      async loginWithEmail(credits: { email: string; password: string }) {
        const { error } = await authRepository.loginWithEmail(credits);

        if (error) {
          return { success: false, error: error.message };
        } else {
          const user = await authRepository.getUser();
          patchState(store, { user });
          return { success: true, error: null };
        }
      },

      async resetPasswordForEmail(email: string) {
        const { error } = await authRepository.resetPasswordForEmail(email);

        if (error) {
          return { success: false, error: error.message };
        } else {
          return { success: true };
        }
      },

      async updatePassword(password: string) {
        const { error } = await authRepository.updatePassword(password);

        if (error) {
          return { success: false, error: error.message };
        } else {
          return { success: true };
        }
      },
    }),
  ),
);
