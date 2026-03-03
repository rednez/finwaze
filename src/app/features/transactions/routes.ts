import { Routes } from '@angular/router';

export const transactionsRoutes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./pages/transactions-list').then((c) => c.TransactionsList),
  },
  {
    path: 'create',
    loadComponent: () =>
      import('./pages/edit-transaction').then((c) => c.EditTransaction),
    data: { isCreating: true },
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./pages/edit-transaction').then((c) => c.EditTransaction),
  },
];
