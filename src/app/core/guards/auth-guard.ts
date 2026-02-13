import { inject } from '@angular/core';
import { CanMatchFn, RedirectCommand, Router } from '@angular/router';

export const authGuard: CanMatchFn = (route, segments) => {
  const router = inject(Router);
  return new RedirectCommand(router.parseUrl('/login'));
};
