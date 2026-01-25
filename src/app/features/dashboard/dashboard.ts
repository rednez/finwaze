import { Component } from '@angular/core';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { AmountWidget } from './ui/amount-widget/amount-widget';
import { MoneyFlowWidget } from './ui/money-flow-widget/money-flow-widget';

@Component({
  selector: 'app-dashboard',
  imports: [CardModule, TagModule, AmountWidget, MoneyFlowWidget],
  templateUrl: './dashboard.html',
})
export class Dashboard {
  readonly amountWidgets = [
    {
      title: 'Total balance',
      amount: 123.43,
      percent: 12.1,
      isPositive: true,
      isGrowth: true,
    },
    {
      title: 'Income',
      amount: 8500.43,
      percent: 8.6,
      isPositive: false,
      isGrowth: false,
    },
    {
      title: 'Expenses',
      amount: 4200.1,
      percent: 5.2,
      isPositive: false,
      isGrowth: true,
    },
  ];
}
