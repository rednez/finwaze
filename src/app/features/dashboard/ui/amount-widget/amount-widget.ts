import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardFailedState } from '@shared/ui/card-failed-state';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { FinancialTrendBadge } from '@shared/ui/financial-trend-badge';
import { StyledAmount } from '@shared/ui/styled-amount';
import { CardModule } from 'primeng/card';
import { SkeletonModule } from 'primeng/skeleton';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-amount-widget',
  imports: [
    Card,
    StyledAmount,
    CardModule,
    TagModule,
    FinancialTrendBadge,
    SkeletonModule,
    CardFailedState,
    CardHeader,
    CardHeaderTitle,
  ],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>
          {{ title() }}
        </app-card-header-title>
      </app-card-header>

      @if (!isLoading()) {
        @if (isError()) {
          <app-card-failed-state />
        } @else {
          <app-styled-amount
            [currency]="currency() || ''"
            [amount]="amount()"
          />
          <div class="mt-2 flex items-center">
            <app-financial-trend-badge
              [currentAmount]="amount()"
              [previousAmount]="previousAmount()"
              [growTrendIsGood]="growTrendIsGood()"
            />
            <span class="ml-1 text-gray-400 text-sm">vs last month</span>
          </div>
        }
      } @else {
        <p-skeleton height="32px" />
        <p-skeleton height="16px" class="mt-5" />
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AmountWidget {
  readonly isLoading = input(false);
  readonly isError = input(false);
  readonly title = input.required<string>();
  readonly amount = input(0);
  readonly currency = input<string>();
  readonly previousAmount = input(0);
  readonly growTrendIsGood = input(true);
}
