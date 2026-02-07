import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BreadcrumbModule } from 'primeng/breadcrumb';
import { BudgetState } from './services/budget-state';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { DatePipe } from '@angular/common';

@Component({
  imports: [RouterOutlet, BreadcrumbModule, ProgressSpinnerModule],
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

      <div class="w-fit p-1 size-6">
        @if (isLoading()) {
          <p-progress-spinner strokeWidth="7" class="size-5!" />
        }
      </div>
    </div>

    <router-outlet />
  `,
  providers: [DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Budget {
  private readonly budgetState = inject(BudgetState);
  private datePipe = inject(DatePipe);

  protected readonly isLoading = this.budgetState.isLoadingCategories;

  protected readonly breadcrumbItems = computed(() => {
    const home = ['Budget'];

    if (this.budgetState.selectedMonth()) {
      home.push(
        this.datePipe.transform(this.budgetState.selectedMonth(), 'MMM y') ||
          '',
      );
    }
    if (this.budgetState.selectedCurrency()) {
      home.push(this.budgetState.selectedCurrency());
    }

    const path: { label: string; routerLink?: string }[] = [
      {
        label: home.join(' – '),
        routerLink: this.budgetState.selectedGroupName()
          ? '/budget'
          : undefined,
      },
    ];

    if (this.budgetState.selectedGroupName()) {
      path.push({ label: this.budgetState.selectedGroupName() });
    }

    return path;
  });

  constructor() {
    this.budgetState.reset();
  }
}
