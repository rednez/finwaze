import { inject } from '@angular/core';
import { CanMatchFn } from '@angular/router';
import { APP_CONFIG } from '@core/configs';

export const underDevelopmentGuard: CanMatchFn = (route, segments) => {
  const config = inject(APP_CONFIG);
  return config.isUnderDevelopment;
};
