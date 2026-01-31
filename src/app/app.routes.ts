import { Routes } from '@angular/router';
import { PageNotFound } from './features/page-not-found/page-not-found';

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
  { path: '**', component: PageNotFound },
];
