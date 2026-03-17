import { Routes } from '@angular/router';

export const walletRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/wallet').then((c) => c.Wallet),
  },
  {
    path: 'create',
    loadComponent: () =>
      import('./pages/new-account').then((c) => c.NewAccount),
  },
  {
    path: 'transfer',
    loadComponent: () => import('./pages/transfer').then((c) => c.Transfer),
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./pages/account-settings').then((c) => c.AccountSettings),
  },
];
