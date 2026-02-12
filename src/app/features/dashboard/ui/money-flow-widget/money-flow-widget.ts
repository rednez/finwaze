import { ChangeDetectionStrategy, Component } from '@angular/core';
import { Card } from '@shared/ui/card';
import { MoneyFlowChart } from '../money-flow-chart/money-flow-chart';

@Component({
  selector: 'app-money-flow-widget',
  imports: [Card, MoneyFlowChart],
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">Money flow</div>
      <app-money-flow-chart
        [labels]="labels"
        [incomes]="incomes"
        [expenses]="expenses"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MoneyFlowWidget {
  labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
  incomes = [1200, 1800, 1720, 2100, 1500, 1900, 1820];
  expenses = [1102, 1760, 1300, 1930, 1650, 1900, 1790];
}
