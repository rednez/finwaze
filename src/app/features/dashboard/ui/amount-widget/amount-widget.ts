import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@shared/ui/card';
import { FinancialTrendBadge } from '@shared/ui/financial-trend-badge';
import { StyledAmount } from '@shared/ui/styled-amount';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-amount-widget',
  imports: [Card, StyledAmount, CardModule, TagModule, FinancialTrendBadge],
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">{{ title() }}</div>
      <app-styled-amount currency="USD" [amount]="amount()" />
      <div class="mt-2 flex items-center">
        <app-financial-trend-badge
          [currentAmount]="amount()"
          [previousAmount]="previousAmount()"
          [growTrendIsGood]="growTrendIsGood()"
        />
        <span class="ml-1 text-gray-400 text-sm">vs last month</span>
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AmountWidget {
  readonly title = input.required<string>();
  readonly amount = input(0);
  readonly previousAmount = input(0);
  readonly growTrendIsGood = input(true);
}
