import { DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { TooltipModule } from 'primeng/tooltip';
import { MoneyFlowChart } from '../money-flow-chart/money-flow-chart';

@Component({
  selector: 'app-money-flow-widget',
  imports: [Card, MoneyFlowChart, CardHeader, CardHeaderTitle, TooltipModule],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title class="flex items-center gap-2">
          <div>Monthly Account Flow</div>
          <span
            class="material-symbols-rounded"
            pTooltip="The expenses and incomes based on charged amounts for the last month, for selected currencies."
          >
            info
          </span>
        </app-card-header-title>
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
