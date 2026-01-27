import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { NavigatorHelper } from '@services/navigator-helper';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-bottom-nav-bar',
  imports: [ButtonModule],
  template: `
    <div class="flex gap-2 items-center">
      @for (item of items; track item.name) {
        <p-button
          [rounded]="true"
          [text]="true"
          [outlined]="true"
          severity="secondary"
          size="large"
          (onClick)="navigateTo(item.name)"
        >
          <span
            class="material-icons-outlined "
            [class.text-primary-500]="currentPath() === item.name"
          >
            {{ item.icon }}
          </span>
        </p-button>
      }
    </div>
  `,
  host: {
    class:
      'min-[500px]:hidden z-10 fixed bottom-4 left-1/2 transform -translate-x-1/2 bg-white dark:bg-gray-900 border border-gray-100 dark:border-gray-600 rounded-3xl p-2 shadow-lg',
  },
})
export class BottomNavBar {
  private readonly router = inject(Router);
  private readonly navigatorHelper = inject(NavigatorHelper);

  readonly currentPath = this.navigatorHelper.currentFeatureName;
  readonly items = [
    { name: 'dashboard', icon: 'dashboard' },
    { name: 'transactions', icon: 'receipt' },
    { name: 'budget', icon: 'savings' },
  ];

  navigateTo(name: string) {
    this.router.navigate([name]);
  }
}
