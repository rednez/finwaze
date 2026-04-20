import { LANDING_TRANSLATIONS } from './landing.translations';
import { LOGIN_TRANSLATIONS } from './login.translations';

export type Lang = 'en' | 'uk' | 'cs';

export const TRANSLATIONS = {
  en: { landing: LANDING_TRANSLATIONS.en, login: LOGIN_TRANSLATIONS.en },
  uk: { landing: LANDING_TRANSLATIONS.uk, login: LOGIN_TRANSLATIONS.uk },
  cs: { landing: LANDING_TRANSLATIONS.cs, login: LOGIN_TRANSLATIONS.cs },
} satisfies Record<
  Lang,
  {
    landing: typeof LANDING_TRANSLATIONS.en;
    login: typeof LOGIN_TRANSLATIONS.en;
  }
>;
