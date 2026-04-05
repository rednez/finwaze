import { Routes } from '@angular/router';

export const budgetRoutes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./layout/budget-layout').then((c) => c.BudgetLayout),
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./pages/total-budget').then((c) => c.TotalBudget),
      },
      {
        path: 'groups/:id',
        loadComponent: () =>
          import('./pages/budget-by-group').then((c) => c.BudgetByGroup),
      },
      {
        path: 'create',
        loadComponent: () =>
          import('./pages/create-budget').then((c) => c.CreateBudget),
      },
      {
        path: 'edit',
        loadComponent: () =>
          import('./pages/create-budget').then((c) => c.CreateBudget),
      },
    ],
  },
];
