import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('@features').then((c) => c.Dashboard),
  },
  {
    path: 'transactions',
    loadComponent: () => import('@features').then((c) => c.Transactions),
  },
];
