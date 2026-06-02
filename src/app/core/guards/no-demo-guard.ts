import { inject } from '@angular/core';
import { CanActivateFn, RedirectCommand, Router } from '@angular/router';
import { DemoModeService } from '@core/services/demo-mode/demo-mode.service';

export const noDemoGuard: CanActivateFn = () => {
  const router = inject(Router);
  const demoModeService = inject(DemoModeService);

  if (demoModeService.isDemo()) {
    return new RedirectCommand(router.parseUrl('/dashboard'));
  }

  return true;
};
