import { Component, computed, inject, input, signal } from '@angular/core';
import { AuthService } from '@core/services/auth-service';
import { NavigatorHelper } from '@core/services/navigator-helper';
import { AuthStore } from '@core/store/auth-store';
import { UserAvatar, UserData } from './user-avatar/user-avatar';

@Component({
  selector: 'app-top-bar',
  imports: [UserAvatar],
  template: `
    <div>
      @if (hasTitle()) {
        <h1 class="text-2xl font-medium">{{ title() }}</h1>
        <div class="hidden sm:block text-sm text-muted-color">
          {{ description() }}
        </div>
      }
    </div>

    <app-user-avatar [user]="user()" (logout)="logout()" />
  `,
  host: {
    class: 'flex justify-between gap-1 p-4',
  },
})
export class TopBar {
  readonly hasTitle = input(true);

  private readonly navigatorHelper = inject(NavigatorHelper);
  private readonly auth = inject(AuthService);
  private readonly authStore = inject(AuthStore);

  private readonly currentPath = this.navigatorHelper.currentFeatureName;

  private readonly pages = {
    dashboard: {
      title: 'Dashboard',
      description: 'Brief overview of your financial status',
    },
    transactions: {
      title: 'Transactions',
      description: 'View and manage your transactions',
    },
    wallet: {
      title: 'Wallet',
      description: 'Manage your accounts and balances',
    },
    budget: {
      title: 'Budget',
      description: 'Create and track your budgets',
    },
    goals: {
      title: 'Goals',
      description: 'Set and track your financial goals',
    },
    analytics: {
      title: 'Analytics',
      description: 'Analyze your financial data',
    },
  };
  protected readonly user = signal<UserData | undefined>(undefined);

  protected readonly title = computed(
    () =>
      this.pages[this.currentPath() as keyof typeof this.pages]?.title || '',
  );

  protected readonly description = computed(
    () =>
      this.pages[this.currentPath() as keyof typeof this.pages]?.description ||
      '',
  );

  constructor() {
    this.getUser();
  }

  protected async logout() {
    await this.auth.logOut();
  }

  private async getUser() {
    const user = this.authStore.user();
    if (user) {
      this.user.set({
        name: user.name,
        email: user.email,
        imgUrl: user.imgUrl,
      });
    }
  }
}
