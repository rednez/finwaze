import { Routes } from '@angular/router';

export const routes: Routes = [
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
  { path: '**', redirectTo: '/dashboard' },
];
