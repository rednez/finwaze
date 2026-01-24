import { Component, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { filter, map } from 'rxjs';
import { SidebarNavItem } from './sidebar-nav-item';
import { SidebarToggleBtn } from './sidebar-toggle-btn';

@Component({
  selector: 'app-sidebar',
  imports: [ButtonModule, SidebarToggleBtn, SidebarNavItem],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar {
  private readonly router = inject(Router);

  currentPath = toSignal(
    this.router.events.pipe(
      filter((event) => event instanceof NavigationEnd),
      map(() => this.router.url.split('/')[1]),
    ),
    { initialValue: this.router.url },
  );

  closed = signal(false);

  items = [
    { name: 'dashboard', label: 'Dashboard', icon: 'dashboard' },
    { name: 'transactions', label: 'Transactions', icon: 'receipt' },
    { name: 'wallet', label: 'Wallet', icon: 'wallet' },
    { name: 'budget', label: 'Budget', icon: 'savings' },
    { name: 'goals', label: 'Goals', icon: 'radar' },
    { name: 'analytics', label: 'Analytics', icon: 'analytics' },
  ];

  toggle(e: boolean) {
    this.closed.set(e);
  }

  selectNavItem(name: string) {
    this.router.navigate([name]);
  }
}
