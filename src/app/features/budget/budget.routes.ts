import { Routes } from '@angular/router';
import { budgetByGroupGuard } from './guards/budget-by-group-guard';
import { categoriesResolver } from './resolvers/categories-resolver';
import { mostExpensesResolver } from './resolvers/most-expenses-resolver';

export const budgetRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./budget').then((c) => c.Budget),
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
        canActivate: [budgetByGroupGuard],
        resolve: {
          categories: categoriesResolver,
          mostExpenses: mostExpensesResolver,
        },
      },
      {
        path: 'create',
        loadComponent: () =>
          import('./pages/create-budget').then((c) => c.CreateBudget),
      },
    ],
  },
];
