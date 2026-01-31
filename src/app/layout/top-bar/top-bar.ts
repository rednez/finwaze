import { Component, computed, inject } from '@angular/core';
import { NavigatorHelper } from '@services/navigator-helper';
import { UserAvatar } from './user-avatar/user-avatar';

@Component({
  selector: 'app-top-bar',
  imports: [UserAvatar],
  template: `
    <div>
      <h1 class="text-2xl font-medium">{{ title() }}</h1>
      <div class="hidden sm:block text-sm text-muted-color">
        {{ description() }}
      </div>
    </div>

    <app-user-avatar name="John Doe" email="john@gmail.com" />
  `,
  host: {
    class: 'flex justify-between gap-1 p-4',
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

  private readonly navigatorHelper = inject(NavigatorHelper);
  private currentPath = this.navigatorHelper.currentFeatureName;

  title = computed(
    () =>
      this.pages[this.currentPath() as keyof typeof this.pages]?.title || '',
  );

  description = computed(
    () =>
      this.pages[this.currentPath() as keyof typeof this.pages]?.description ||
      '',
  );
}
