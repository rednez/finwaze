import { ANALYTICS_TRANSLATIONS } from './analytics.translations';
import { CHANGE_PASSWORD_TRANSLATIONS } from './change-password.translations';
import { BUDGET_TRANSLATIONS } from './budget.translations';
import { CORE_TRANSLATIONS } from './core.translations';
import { DASHBOARD_TRANSLATIONS } from './dashboard.translations';
import { GOALS_TRANSLATIONS } from './goals.translations';
import { GROUPS_TRANSLATIONS } from './groups.translations';
import { LANDING_TRANSLATIONS } from './landing.translations';
import { LOGIN_TRANSLATIONS } from './login.translations';
import { MISC_TRANSLATIONS } from './misc.translations';
import { SHARED_TRANSLATIONS } from './shared.translations';
import { RESET_PASSWORD_TRANSLATIONS } from './reset-password.translations';
import { SIGNIN_TRANSLATIONS } from './signin.translations';
import { SIGNUP_TRANSLATIONS } from './signup.translations';
import { TRANSACTIONS_TRANSLATIONS } from './transactions.translations';
import { WALLET_TRANSLATIONS } from './wallet.translations';

export type Lang = 'en' | 'uk' | 'cs';

export const TRANSLATIONS = {
  en: {
    shared: SHARED_TRANSLATIONS.en,
    core: CORE_TRANSLATIONS.en,
    landing: LANDING_TRANSLATIONS.en,
    login: LOGIN_TRANSLATIONS.en,
    signup: SIGNUP_TRANSLATIONS.en,
    signin: SIGNIN_TRANSLATIONS.en,
    resetPassword: RESET_PASSWORD_TRANSLATIONS.en,
    changePassword: CHANGE_PASSWORD_TRANSLATIONS.en,
    dashboard: DASHBOARD_TRANSLATIONS.en,
    transactions: TRANSACTIONS_TRANSLATIONS.en,
    wallet: WALLET_TRANSLATIONS.en,
    budget: BUDGET_TRANSLATIONS.en,
    goals: GOALS_TRANSLATIONS.en,
    analytics: ANALYTICS_TRANSLATIONS.en,
    groups: GROUPS_TRANSLATIONS.en,
    misc: MISC_TRANSLATIONS.en,
  },
  uk: {
    shared: SHARED_TRANSLATIONS.uk,
    core: CORE_TRANSLATIONS.uk,
    landing: LANDING_TRANSLATIONS.uk,
    login: LOGIN_TRANSLATIONS.uk,
    signup: SIGNUP_TRANSLATIONS.uk,
    signin: SIGNIN_TRANSLATIONS.uk,
    resetPassword: RESET_PASSWORD_TRANSLATIONS.uk,
    changePassword: CHANGE_PASSWORD_TRANSLATIONS.uk,
    dashboard: DASHBOARD_TRANSLATIONS.uk,
    transactions: TRANSACTIONS_TRANSLATIONS.uk,
    wallet: WALLET_TRANSLATIONS.uk,
    budget: BUDGET_TRANSLATIONS.uk,
    goals: GOALS_TRANSLATIONS.uk,
    analytics: ANALYTICS_TRANSLATIONS.uk,
    groups: GROUPS_TRANSLATIONS.uk,
    misc: MISC_TRANSLATIONS.uk,
  },
  cs: {
    shared: SHARED_TRANSLATIONS.cs,
    core: CORE_TRANSLATIONS.cs,
    landing: LANDING_TRANSLATIONS.cs,
    login: LOGIN_TRANSLATIONS.cs,
    signup: SIGNUP_TRANSLATIONS.cs,
    signin: SIGNIN_TRANSLATIONS.cs,
    resetPassword: RESET_PASSWORD_TRANSLATIONS.cs,
    changePassword: CHANGE_PASSWORD_TRANSLATIONS.cs,
    dashboard: DASHBOARD_TRANSLATIONS.cs,
    transactions: TRANSACTIONS_TRANSLATIONS.cs,
    wallet: WALLET_TRANSLATIONS.cs,
    budget: BUDGET_TRANSLATIONS.cs,
    goals: GOALS_TRANSLATIONS.cs,
    analytics: ANALYTICS_TRANSLATIONS.cs,
    groups: GROUPS_TRANSLATIONS.cs,
    misc: MISC_TRANSLATIONS.cs,
  },
} satisfies Record<Lang, {
  shared: typeof SHARED_TRANSLATIONS.en;
  core: typeof CORE_TRANSLATIONS.en;
  landing: typeof LANDING_TRANSLATIONS.en;
  login: typeof LOGIN_TRANSLATIONS.en;
  signup: typeof SIGNUP_TRANSLATIONS.en;
  signin: typeof SIGNIN_TRANSLATIONS.en;
  resetPassword: typeof RESET_PASSWORD_TRANSLATIONS.en;
  changePassword: typeof CHANGE_PASSWORD_TRANSLATIONS.en;
  dashboard: typeof DASHBOARD_TRANSLATIONS.en;
  transactions: typeof TRANSACTIONS_TRANSLATIONS.en;
  wallet: typeof WALLET_TRANSLATIONS.en;
  budget: typeof BUDGET_TRANSLATIONS.en;
  goals: typeof GOALS_TRANSLATIONS.en;
  analytics: typeof ANALYTICS_TRANSLATIONS.en;
  groups: typeof GROUPS_TRANSLATIONS.en;
  misc: typeof MISC_TRANSLATIONS.en;
}>;
