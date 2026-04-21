import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { FinancialTrendBadge } from '@shared/ui/financial-trend-badge';
import { StyledAmount } from '@shared/ui/styled-amount';
import { ButtonModule } from 'primeng/button';
import { FinancialSummaryCardButton } from './financial-summary-card-button/financial-summary-card-button';

@Component({
  selector: 'app-financial-summary-card',
  imports: [
    CommonModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    StyledAmount,
    FinancialTrendBadge,
    ButtonModule,
    FinancialSummaryCardButton,
    TranslatePipe,
  ],
  templateUrl: './financial-summary-card.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'block grow',
  },
})
export class FinancialSummaryCard {
  readonly title = input('');
  readonly currentAmount = input(0);
  readonly previousAmount = input(0);
  readonly currency = input('');
  readonly growTrendIsGood = input(true);
  readonly transactionCount = input(0);
  readonly groupsCount = input(0);

  protected readonly diffAmount = computed(() =>
    Math.abs(this.currentAmount() - this.previousAmount()),
  );

  protected readonly comparedText = computed(() =>
    this.currentAmount() > this.previousAmount()
      ? 'more'
      : this.currentAmount() === this.previousAmount()
        ? 'The same'
        : 'less',
  );
}
