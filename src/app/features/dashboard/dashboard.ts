import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { AppStore } from '@core/store/app-store';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { AmountWidget } from './ui/amount-widget/amount-widget';
import { BudgetWidget } from './ui/budget-widget/budget-widget';
import { MoneyFlowWidget } from './ui/money-flow-widget/money-flow-widget';
import { RecentTransactionsWidget } from '@shared/ui/recent-transactions-widget';
import { SavingGoalsWidget } from './ui/saving-goals-widget/saving-goals-widget';

@Component({
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
          [previousAmount]="widget.previousAmount"
          [growTrendIsGood]="widget.growTrendIsGood"
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
      <app-recent-transactions-widget
        class="grow overflow-x-auto"
        [transactions]="recentTransactions()"
      />
      <app-saving-goals-widget class="grow" />
    </div>
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Dashboard {
  private readonly store = inject(AppStore);

  readonly amountWidgets = [
    {
      title: 'Total balance',
      amount: 34123.43,
      previousAmount: 32000,

      growTrendIsGood: true,
    },
    {
      title: 'Income',
      amount: 8500.43,
      previousAmount: 7800,

      growTrendIsGood: true,
    },
    {
      title: 'Expenses',
      amount: 4200.1,
      previousAmount: 3200.43,
      growTrendIsGood: false,
    },
  ];

  protected readonly recentTransactions = computed(() =>
    this.store.transactions().slice(0, 3),
  );
}
