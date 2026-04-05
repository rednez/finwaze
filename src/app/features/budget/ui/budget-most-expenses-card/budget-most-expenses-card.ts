import {
  ChangeDetectionStrategy,
  Component,
  inject,
  input,
} from '@angular/core';
import { Router } from '@angular/router';
import { Card } from '@shared/ui/card';
import { CardEmptyState } from '@shared/ui/card-empty-state';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { SkeletonModule } from 'primeng/skeleton';
import { MonthlyExpense } from '../../models';
import { BudgetExpenseItem } from './budget-expense-item/budget-expense-item';

@Component({
  selector: 'app-budget-most-expenses-card',
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    BudgetExpenseItem,
    CardEmptyState,
    SkeletonModule,
  ],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        <app-card-header-title>Most expenses</app-card-header-title>
      </app-card-header>

      @if (loading()) {
        <div class="flex flex-col gap-3">
          @for (i of skeletonRows; track i) {
            <div class="flex items-center justify-between">
              <div class="flex flex-col gap-1">
                <p-skeleton width="6rem" height="1.25rem" />
                <p-skeleton width="8rem" height="0.875rem" />
              </div>
              <p-skeleton width="4rem" height="1.5rem" borderRadius="1rem" />
            </div>
          }
        </div>
      } @else {
        <div class="flex flex-col gap-2">
          @for (expense of expenses(); track expense.id) {
            <app-budget-expense-item
              [name]="expense.name"
              [currentAmount]="expense.selectedMonthAmount"
              [previousPeriodAmount]="expense.previousMonthAmount"
              [currency]="currency()"
            />
          }
        </div>

        @if (expenses().length === 0) {
          <app-card-empty-state
            title="No expenses found"
            actionBtnLabel="Create expense"
            (actionBtnClicked)="gotoCreateTransaction()"
          />
        }
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetMostExpensesCard {
  readonly loading = input(false);
  readonly currency = input<string>();
  readonly expenses = input<MonthlyExpense[]>([]);

  protected readonly skeletonRows = [1, 2, 3, 4, 5];

  private readonly router = inject(Router);

  protected gotoCreateTransaction() {
    this.router.navigate(['transactions', 'create']);
  }
}
