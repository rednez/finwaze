import { inject } from '@angular/core';
import { CanActivateFn, RedirectCommand, Router } from '@angular/router';
import { AuthStore } from '@core/store/auth-store';

export const authGuard: CanActivateFn = async (route, segments) => {
  const router = inject(Router);
  const authStore = inject(AuthStore);

  await authStore.init();

  if (!authStore.isAuthorized()) {
    return new RedirectCommand(router.parseUrl('/login'));
  } else {
    return true;
  }
};
