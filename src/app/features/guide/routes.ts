import { Routes } from '@angular/router';

export const guideRoutes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/guide-hub').then((c) => c.GuideHub),
  },
  {
    path: ':topic',
    loadComponent: () =>
      import('./pages/guide-article').then((c) => c.GuideArticle),
  },
];
