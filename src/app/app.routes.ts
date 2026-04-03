import { Routes } from '@angular/router';
import {
  authGuard,
  guestGuard,
  hasAccountsGuard,
  underDevelopmentGuard,
} from '@core/guards';
import { PageNotFound } from './features/page-not-found';

export const routes: Routes = [
  {
    path: '',
    canMatch: [underDevelopmentGuard],
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/under-construction').then(
            (c) => c.UnderConstruction,
          ),
      },
      { path: '**', redirectTo: '/' },
    ],
  },
  {
    path: '',
    canMatch: [guestGuard],
    loadComponent: () =>
      import('@core/layout/guest-layout').then((c) => c.GuestLayout),
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/landing').then((c) => c.Landing),
      },
      {
        path: 'login',
        loadComponent: () => import('./features/login').then((c) => c.Login),
      },
      { path: '**', redirectTo: 'login' },
    ],
  },
  {
    path: '',
    canActivate: [authGuard],
    canMatch: [hasAccountsGuard],
    loadComponent: () =>
      import('@core/layout/app-layout').then((c) => c.AppLayout),
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard').then((c) => c.Dashboard),
      },
      {
        path: 'transactions',
        loadChildren: () =>
          import('./features/transactions').then((c) => c.transactionsRoutes),
      },
      {
        path: 'categories',
        loadComponent: () =>
          import('./features/groups-and-categories').then(
            (c) => c.GroupsAndCategories,
          ),
      },
      {
        path: 'wallet',
        loadChildren: () =>
          import('./features/wallet').then((c) => c.walletRoutes),
      },
      {
        path: 'budget',
        loadChildren: () =>
          import('./features/budget/routes').then((c) => c.budgetRoutes),
      },
      {
        path: 'goals',
        loadChildren: () =>
          import('./features/goals/routes').then((c) => c.goalsRoutes),
      },
      {
        path: 'analytics',
        loadComponent: () =>
          import('./features/analytics').then((c) => c.Analytics),
      },
      { path: '**', redirectTo: 'dashboard' },
    ],
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () =>
      import('@core/layout/setup-layout').then((c) => c.SetupLayout),
    children: [
      {
        path: '**',
        loadComponent: () =>
          import('./features/setup-account').then((c) => c.SetupAccount),
      },
    ],
  },
  { path: '**', component: PageNotFound },
];
