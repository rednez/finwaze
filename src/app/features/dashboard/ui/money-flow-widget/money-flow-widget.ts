import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  signal,
} from '@angular/core';
import { Card } from '@shared/ui/card';
import { MoneyFlowChart } from '../money-flow-chart/money-flow-chart';
import { DatePipe } from '@angular/common';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';

@Component({
  selector: 'app-money-flow-widget',
  imports: [Card, MoneyFlowChart, CardHeader, CardHeaderTitle],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>Money flow</app-card-header-title>
      </app-card-header>

      <app-money-flow-chart
        [labels]="chartLabels()"
        [incomes]="incomes()"
        [expenses]="expenses()"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [DatePipe],
})
export class MoneyFlowWidget {
  private readonly datePipe = inject(DatePipe);

  readonly months = input<Date[]>([]);
  readonly incomes = input<number[]>([]);
  readonly expenses = input<number[]>([]);

  protected readonly chartLabels = computed(() =>
    this.months().map(
      (date) => this.datePipe.transform(date, 'MMM yy') || 'NA',
    ),
  );
}
