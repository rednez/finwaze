import { Component, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { NavigatorHelper } from '@core/services/navigator-helper';
import { SupabaseService } from '@core/services/supabase.service';
import { UserAvatar, UserData } from './user-avatar/user-avatar';

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

    <app-user-avatar [user]="user()" (logout)="logout()" />
  `,
  host: {
    class: 'flex justify-between gap-1 p-4',
  },
})
export class TopBar {
  private readonly navigatorHelper = inject(NavigatorHelper);
  private readonly supabase = inject(SupabaseService);
  private readonly router = inject(Router);

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
    await this.supabase.signOut();
    this.router.navigate(['login']);
  }

  private async getUser() {
    const user = await this.supabase.getUser();
    if (user) {
      this.user.set({
        name: user.user_metadata['full_name'] || '',
        email: user.email || '',
        imgUrl: user.user_metadata['avatar_url'] || '',
      });
    }
  }
}
