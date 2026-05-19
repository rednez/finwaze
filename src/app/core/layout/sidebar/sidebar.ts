import { Component, DestroyRef, computed, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { NavigatorHelper } from '@core/services/navigator-helper';
import { ResponsiveHelper } from '@core/services/responsive-helper';
import { LocalizationService } from '@core/services/localization.service';
import { AuthStore } from '@core/store/auth-store';
import { ThemeSwitcher } from '@shared/ui/theme-switcher';
import { ButtonModule } from 'primeng/button';
import { Logo } from './logo';
import { SidebarNavItem } from './sidebar-nav-item/sidebar-nav-item';
import { SidebarToggleBtn } from './sidebar-toggle-btn/sidebar-toggle-btn';

@Component({
  selector: 'app-sidebar',
  imports: [
    ButtonModule,
    SidebarToggleBtn,
    SidebarNavItem,
    Logo,
    ThemeSwitcher,
  ],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar {
  private readonly router = inject(Router);
  private readonly navigatorHelper = inject(NavigatorHelper);
  private readonly responsiveHelper = inject(ResponsiveHelper);
  private readonly destroyRef = inject(DestroyRef);
  private readonly authStore = inject(AuthStore);
  private readonly localizationService = inject(LocalizationService);

  private t = (key: string) => this.localizationService.translate(key);

  readonly currentPath = this.navigatorHelper.currentFeatureName;

  readonly closed = signal(false);

  readonly windowWidth = this.responsiveHelper.windowWidth.pipe(
    takeUntilDestroyed(this.destroyRef),
  );

  readonly items = computed(() => [
    {
      name: 'dashboard',
      label: this.t('core.sidebar.dashboard'),
      icon: 'dashboard',
    },
    {
      name: 'transactions',
      label: this.t('core.sidebar.transactions'),
      icon: 'receipt_long',
    },
    {
      name: 'categories',
      label: this.t('core.sidebar.categories'),
      icon: 'group_work',
    },
    {
      name: 'wallet',
      label: this.t('core.sidebar.wallet'),
      icon: 'account_balance_wallet',
    },
    {
      name: 'budget',
      label: this.t('core.sidebar.budget'),
      icon: 'donut_small',
    },
    { name: 'goals', label: this.t('core.sidebar.goals'), icon: 'savings' },
    {
      name: 'analytics',
      label: this.t('core.sidebar.analytics'),
      icon: 'analytics',
    },
  ]);

  readonly logoutLabel = computed(() => this.t('core.sidebar.logout'));

  constructor() {
    this.windowWidth.subscribe(this.handleWidthChanges);
  }

  protected toggle() {
    this.closed.update((v) => !v);
  }

  protected selectNavItem(name: string) {
    this.router.navigate([name]);
  }

  protected async logout() {
    await this.authStore.logOut();
    this.router.navigate(['login']);
  }

  private handleWidthChanges = (width: number) => {
    if (width <= 640) {
      this.closed.set(true);
    } else {
      this.closed.set(false);
    }
  };
}
