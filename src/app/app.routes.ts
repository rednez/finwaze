import { Routes } from '@angular/router';
import { PageNotFound } from './features/page-not-found';
import { guestGuard, authGuard } from '@core/guards';

export const routes: Routes = [
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
    ],
  },
  {
    path: '',
    canMatch: [authGuard],
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
        loadComponent: () =>
          import('./features/transactions').then((c) => c.Transactions),
      },
      {
        path: 'wallet',
        loadComponent: () => import('./features/wallet').then((c) => c.Wallet),
      },
      {
        path: 'budget',

        loadChildren: () =>
          import('./features/budget/budget.routes').then((c) => c.budgetRoutes),
      },
      {
        path: 'goals',
        loadComponent: () => import('./features/goals').then((c) => c.Goals),
      },
      {
        path: 'analytics',
        loadComponent: () =>
          import('./features/analytics').then((c) => c.Analytics),
      },
    ],
  },
  { path: '**', component: PageNotFound },
];
