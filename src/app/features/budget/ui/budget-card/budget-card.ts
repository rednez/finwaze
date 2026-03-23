import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { ButtonModule } from 'primeng/button';
import { SkeletonModule } from 'primeng/skeleton';
import { BudgetCardChart } from './budget-card-chart/budget-card-chart';
import { BudgetCardSummary } from './budget-card-summary/budget-card-summary';

@Component({
  selector: 'app-budget-card',
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    ButtonModule,
    BudgetCardChart,
    BudgetCardSummary,
    SkeletonModule,
  ],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        @if (loading()) {
          <p-skeleton width="7rem" height="1.25rem" />
        } @else {
          <ng-container>
            <app-card-header-title>{{ name() }}</app-card-header-title>
          </ng-container>
          <ng-container>
            <div append-right>
              <ng-content select="[card-actions]" />
            </div>
          </ng-container>
        }
      </app-card-header>

      @if (loading()) {
        <div class="flex gap-4 items-end">
          <!-- donut chart placeholder -->
          <p-skeleton shape="circle" size="11.5rem" />

          <!-- summary placeholder -->
          <div class="flex flex-col gap-3">
            <div class="flex flex-col gap-1">
              <p-skeleton width="2.8rem" height="0.75rem" />
              <p-skeleton width="6.5rem" height="1.5rem" />
              <p-skeleton width="4rem" height="0.875rem" />
            </div>
            <p-skeleton width="4.5rem" height="1.5rem" borderRadius="1rem" />
          </div>
        </div>
      } @else {
        <div class="flex gap-4 items-end">
          <app-budget-card-chart
            [plannedAmount]="plannedAmount()"
            [spentAmount]="spentAmount()"
            [currency]="currencyCode()"
          />

          <app-budget-card-summary
            [plannedAmount]="plannedAmount()"
            [spentAmount]="spentAmount()"
            [currency]="currencyCode()"
          />
        </div>
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetCard {
  readonly loading = input(false);
  readonly name = input('');
  readonly plannedAmount = input(0);
  readonly spentAmount = input(0);
  readonly currencyCode = input<string>();
}
