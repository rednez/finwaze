import { Routes } from '@angular/router';
import { PageNotFound } from './features/page-not-found';

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
  {
    path: 'wallet',
    loadComponent: () => import('./features/wallet').then((c) => c.Wallet),
  },
  {
    path: 'goals',
    loadComponent: () => import('./features/goals').then((c) => c.Goals),
  },
  { path: '**', component: PageNotFound },
];
