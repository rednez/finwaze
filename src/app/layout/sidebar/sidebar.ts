import { Component, DestroyRef, inject, OnInit, signal } from '@angular/core';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { debounceTime, filter, fromEvent, map, startWith, tap } from 'rxjs';
import { SidebarNavItem } from './sidebar-nav-item';
import { SidebarToggleBtn } from './sidebar-toggle-btn';

@Component({
  selector: 'app-sidebar',
  imports: [ButtonModule, SidebarToggleBtn, SidebarNavItem],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar implements OnInit {
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  currentPath = toSignal(
    this.router.events.pipe(
      filter((event) => event instanceof NavigationEnd),
      map(() => this.router.url.split('/')[1]),
    ),
    { initialValue: this.router.url },
  );

  closed = signal(false);

  windowWidth = fromEvent(window, 'resize').pipe(
    debounceTime(100),
    map(() => window.innerWidth),
    takeUntilDestroyed(this.destroyRef),
    startWith(window.innerWidth),
  );

  items = [
    { name: 'dashboard', label: 'Dashboard', icon: 'dashboard' },
    { name: 'transactions', label: 'Transactions', icon: 'receipt' },
    { name: 'wallet', label: 'Wallet', icon: 'wallet' },
    { name: 'budget', label: 'Budget', icon: 'savings' },
    { name: 'goals', label: 'Goals', icon: 'radar' },
    { name: 'analytics', label: 'Analytics', icon: 'analytics' },
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
    if (width <= 800) {
      this.closed.set(true);
    } else {
      this.closed.set(false);
    }
  };
}
