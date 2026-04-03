import { Routes } from '@angular/router';

export const goalsRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/goals').then((c) => c.Goals),
  },
  {
    path: 'create',
    loadComponent: () => import('./pages/edit-goal').then((c) => c.EditGoal),
  },
  {
    path: ':id',
    loadComponent: () => import('./pages/edit-goal').then((c) => c.EditGoal),
  },
];
