import { Component, computed, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router } from '@angular/router';
import { filter, map } from 'rxjs';
import { UserAvatar } from './user-avatar/user-avatar';

@Component({
  selector: 'app-top-bar',
  imports: [UserAvatar],
  template: `<div>
      <h1 class="text-2xl font-medium">{{ title() }}</h1>
      <div class="text-sm text-gray-400">{{ description() }}</div>
    </div>

    <app-user-avatar name="John Doe" email="john@gmail.com" /> `,
  host: {
    class: 'flex justify-between p-4',
  },
})
export class TopBar {
  private readonly pages = {
    dashboard: {
      title: 'Dashboard',
      description: 'Brief overview of your financial status',
    },
    transactions: {
      title: 'Transactions',
      description: 'View and manage your transactions',
    },
  };

  private readonly router = inject(Router);

  private currentPath = toSignal(
    this.router.events.pipe(
      filter((event) => event instanceof NavigationEnd),
      map(() => this.router.url.split('/')[1]),
    ),
    { initialValue: this.router.url },
  );

  title = computed(
    () => this.pages[this.currentPath() as keyof typeof this.pages]?.title || 'Unknown',
  );

  description = computed(
    () => this.pages[this.currentPath() as keyof typeof this.pages]?.description || '',
  );
}
