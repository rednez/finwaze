import { InjectionToken } from '@angular/core';

export interface AppConfig {
  isUnderDevelopment: boolean;
}

export const APP_CONFIG = new InjectionToken<AppConfig>('app.config');
