import { inject } from '@angular/core';
import { CanMatchFn } from '@angular/router';
import { AuthStore } from '@core/store/auth-store';

export const guestGuard: CanMatchFn = async () => {
  const authStore = inject(AuthStore);
  await authStore.init();

  return !authStore.isAuthorized();
};
