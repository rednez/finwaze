import { Component } from '@angular/core';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { AmountWidget } from './ui/amount-widget/amount-widget';
import { MoneyFlowWidget } from './ui/money-flow-widget/money-flow-widget';
import { BudgetWidget } from './ui/budget-widget/budget-widget';
import { RecentTransactionsWidget } from './ui/recent-transactions-widget/recent-transactions-widget';
import { SavingGoalsWidget } from './ui/saving-goals-widget/saving-goals-widget';

@Component({
  selector: 'app-dashboard',
  imports: [
    CardModule,
    TagModule,
    AmountWidget,
    MoneyFlowWidget,
    BudgetWidget,
    RecentTransactionsWidget,
    SavingGoalsWidget,
  ],
  template: `
    <div class="flex flex-wrap gap-4 min-w-0">
      @for (widget of amountWidgets; track widget.title) {
        <app-amount-widget
          class="grow"
          [title]="widget.title"
          [amount]="widget.amount"
          [percent]="widget.percent"
          [isPositive]="widget.isPositive"
          [isGrowth]="widget.isGrowth"
        />
      }
    </div>

    <div class="flex flex-wrap gap-4 min-w-0">
      <app-money-flow-widget
        class="grow sm:flex-1 min-w-0 sm:min-w-75 max-w-152 lg:max-w-full"
      />
      <app-budget-widget class="grow md:grow-0" />
    </div>

    <div class="flex flex-wrap gap-4 min-w-0">
      <app-recent-transactions-widget class="grow overflow-x-auto" />
      <app-saving-goals-widget class="grow" />
    </div>
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
})
export class Dashboard {
  readonly amountWidgets = [
    {
      title: 'Total balance',
      amount: 34123.43,
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
