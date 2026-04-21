import { Component, computed, inject, input, signal } from '@angular/core';
import { AuthService } from '@core/services/auth-service';
import { LocalizationService } from '@core/services/localization.service';
import { NavigatorHelper } from '@core/services/navigator-helper';
import { AuthStore } from '@core/store/auth-store';
import { LangSwitcher } from '@shared/ui/lang-switcher';
import { UserAvatar, UserData } from './user-avatar/user-avatar';

@Component({
  selector: 'app-top-bar',
  imports: [UserAvatar, LangSwitcher],
  template: `
    <div>
      @if (hasTitle()) {
        <h1 class="text-2xl font-display font-medium">{{ title() }}</h1>
        <div class="hidden sm:block text-sm text-muted-color">
          {{ description() }}
        </div>
      }
    </div>

    <div class="flex items-center gap-4">
      <app-lang-switcher />
      <app-user-avatar [user]="user()" (logout)="logout()" />
    </div>
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
  private readonly localizationService = inject(LocalizationService);

  private readonly currentPath = this.navigatorHelper.currentFeatureName;
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly user = signal<UserData | undefined>(undefined);

  protected readonly title = computed(() => {
    const path = this.currentPath();
    const keys: Record<string, string> = {
      dashboard: 'core.pages.dashboard.title',
      transactions: 'core.pages.transactions.title',
      categories: 'core.pages.categories.title',
      wallet: 'core.pages.wallet.title',
      budget: 'core.pages.budget.title',
      goals: 'core.pages.goals.title',
      analytics: 'core.pages.analytics.title',
    };
    return keys[path] ? this.t(keys[path]) : '';
  });

  protected readonly description = computed(() => {
    const path = this.currentPath();
    const keys: Record<string, string> = {
      dashboard: 'core.pages.dashboard.description',
      transactions: 'core.pages.transactions.description',
      categories: 'core.pages.categories.description',
      wallet: 'core.pages.wallet.description',
      budget: 'core.pages.budget.description',
      goals: 'core.pages.goals.description',
      analytics: 'core.pages.analytics.description',
    };
    return keys[path] ? this.t(keys[path]) : '';
  });

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
