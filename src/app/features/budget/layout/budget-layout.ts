import { DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { BreadcrumbModule } from 'primeng/breadcrumb';
import { filter, map, startWith } from 'rxjs';
import { BudgetStore } from '../stores';

@Component({
  imports: [RouterOutlet, BreadcrumbModule],
  template: `
    <div class="flex gap-6 pb-4">
      <p-breadcrumb
        [model]="breadcrumbItems()"
        [dt]="{
          root: {
            padding: 0,
          },
        }"
      />
    </div>

    <router-outlet />
  `,
  providers: [DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetLayout {
  private readonly budgetStore = inject(BudgetStore);
  private readonly accountsStore = inject(AccountsStore);
  private readonly datePipe = inject(DatePipe);
  private readonly router = inject(Router);
  private readonly currentUrl = toSignal(
    this.router.events.pipe(
      filter((e) => e instanceof NavigationEnd),
      map((e) => (e as NavigationEnd).urlAfterRedirects),
      startWith(this.router.url),
    ),
  );

  protected readonly breadcrumbItems = computed(() => {
    const home = ['Budget'];

    if (this.budgetStore.month()) {
      home.push(
        this.datePipe.transform(this.budgetStore.month(), 'MMM y') || '',
      );
    }
    if (this.budgetStore.currencyCode()) {
      home.push(this.budgetStore.currencyCode()!);
    }

    const isCreateOrEditPage =
      this.currentUrl()?.includes('create') ||
      this.currentUrl()?.includes('edit');
    const path: { label: string; routerLink?: string }[] = [
      {
        label: home.join(' – '),
        routerLink:
          isCreateOrEditPage || this.budgetStore.selectedGroupName()
            ? '/budget'
            : undefined,
      },
    ];

    if (this.budgetStore.selectedGroupName()) {
      path.push({ label: this.budgetStore.selectedGroupName()! });
    }

    return path;
  });

  constructor() {
    this.initStore();
  }

  private initStore() {
    if (!this.budgetStore.currencyCode()) {
      if (this.accountsStore.selectedCurrencyCode()) {
        this.budgetStore.updateCurrencyCode(
          this.accountsStore.selectedCurrencyCode()!,
        );
      }
    }
  }
}
