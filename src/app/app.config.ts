import {
  ApplicationConfig,
  LOCALE_ID,
  provideBrowserGlobalErrorListeners,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { providePrimeNG } from 'primeng/config';
import { routes } from './app.routes';
import { CustomPreset } from './custom-theme';
import { registerLocaleData } from '@angular/common';
import localeUk from '@angular/common/locales/uk';
import localeCs from '@angular/common/locales/cs';

registerLocaleData(localeUk);
registerLocaleData(localeCs);

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
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
