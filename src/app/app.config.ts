import { registerLocaleData } from '@angular/common';
import localeCs from '@angular/common/locales/cs';
import localeUk from '@angular/common/locales/uk';
import {
  ApplicationConfig,
  LOCALE_ID,
  provideBrowserGlobalErrorListeners,
} from '@angular/core';
import {
  provideRouter,
  withComponentInputBinding,
  withRouterConfig,
} from '@angular/router';
import { providePrimeNG } from 'primeng/config';
import { routes } from './app.routes';
import { CustomPreset } from './custom-theme';

registerLocaleData(localeUk);
registerLocaleData(localeCs);

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(
      routes,
      withComponentInputBinding(),
      withRouterConfig({ onSameUrlNavigation: 'reload' }),
    ),
    providePrimeNG({
      ripple: true,
      theme: {
        preset: CustomPreset,
      },
    }),
    {
      provide: LOCALE_ID,
      useFactory: () =>
        ['uk', 'cs'].includes(navigator.language)
          ? navigator.language
          : 'en-US',
    },
  ],
};
