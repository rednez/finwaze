import { Component, DestroyRef, inject, OnInit, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Router } from '@angular/router';
import { NavigatorHelper } from '@services/navigator-helper';
import { ResponsiveHelper } from '@services/responsive-helper';
import { ButtonModule } from 'primeng/button';
import { Logo } from './logo';
import { SidebarNavItem } from './sidebar-nav-item/sidebar-nav-item';
import { SidebarToggleBtn } from './sidebar-toggle-btn/sidebar-toggle-btn';

@Component({
  selector: 'app-sidebar',
  imports: [ButtonModule, SidebarToggleBtn, SidebarNavItem, Logo],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar implements OnInit {
  private readonly router = inject(Router);
  private readonly navigatorHelper = inject(NavigatorHelper);
  private readonly responsiveHelper = inject(ResponsiveHelper);
  private readonly destroyRef = inject(DestroyRef);

  readonly currentPath = this.navigatorHelper.currentFeatureName;

  readonly closed = signal(false);

  readonly windowWidth = this.responsiveHelper.windowWidth.pipe(
    takeUntilDestroyed(this.destroyRef),
  );

  readonly items = [
    { name: 'dashboard', label: 'Dashboard', icon: 'dashboard' },
    { name: 'transactions', label: 'Transactions', icon: 'receipt' },
    { name: 'wallet', label: 'Wallet', icon: 'account_balance_wallet' },
    { name: 'budget', label: 'Budget', icon: 'donut_small' },
    { name: 'goals', label: 'Goals', icon: 'savings' },
    // { name: 'analytics', label: 'Analytics', icon: 'analytics' },
  ];

  ngOnInit(): void {
    this.windowWidth.subscribe(this.handleWidthChanges);
  }

  toggle() {
    this.closed.update((v) => !v);
  }

  selectNavItem(name: string) {
    this.router.navigate([name]);
  }

  private handleWidthChanges = (width: number) => {
    if (width <= 640) {
      this.closed.set(true);
    } else {
      this.closed.set(false);
    }
  };
}
