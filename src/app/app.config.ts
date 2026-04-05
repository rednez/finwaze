import { registerLocaleData } from '@angular/common';
import localeCs from '@angular/common/locales/cs';
import localeUk from '@angular/common/locales/uk';
import {
  ApplicationConfig,
  LOCALE_ID,
  provideBrowserGlobalErrorListeners,
} from '@angular/core';
import { getAnalytics, provideAnalytics } from '@angular/fire/analytics';
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';
import {
  provideRouter,
  withComponentInputBinding,
  withRouterConfig,
} from '@angular/router';
import { APP_CONFIG } from '@core/configs';
import { environment } from '@env';
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
        options: {
          darkModeSelector: '.dark',
        },
      },
    }),
    {
      provide: LOCALE_ID,
      useFactory: () =>
        ['uk', 'cs'].includes(navigator.language)
          ? navigator.language
          : 'en-US',
    },
    {
      provide: APP_CONFIG,
      useValue: {
        isUnderDevelopment: false,
      },
    },
    provideFirebaseApp(() => initializeApp(environment.firebase)),
    provideAnalytics(() => getAnalytics()),
  ],
};
