import {
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
  inject,
  OnInit,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { RecentTransactionsWidget } from '@shared/ui/recent-transactions-widget';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';
import { take } from 'rxjs';
import { DashboardStore } from './store/dashboard-store';
import { AmountWidget } from './ui/amount-widget/amount-widget';
import { BudgetWidget } from './ui/budget-widget/budget-widget';
import { DashboardFilters } from './ui/dashboard-filters';
import { MoneyFlowWidget } from './ui/money-flow-widget/money-flow-widget';
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
    DashboardFilters,
  ],
  templateUrl: './dashboard.html',
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Dashboard implements OnInit {
  protected readonly store = inject(DashboardStore);
  private readonly destroyRef = inject(DestroyRef);

  readonly amountWidgets = computed(() => {
    const {
      totalBalance,
      previousMonthTotalBalance,
      monthlyIncome,
      previousMonthlyIncome,
      monthlyExpense,
      previousMonthlyExpense,
    } = this.store.totalsSummary();

    return [
      {
        title: 'Total balance',
        amount: totalBalance,
        previousAmount: previousMonthTotalBalance,
        growTrendIsGood: true,
      },
      {
        title: 'Income',
        amount: monthlyIncome,
        previousAmount: previousMonthlyIncome,
        growTrendIsGood: true,
      },
      {
        title: 'Expenses',
        amount: monthlyExpense,
        previousAmount: previousMonthlyExpense,
        growTrendIsGood: false,
      },
    ];
  });

  ngOnInit(): void {
    this.store.currencyCode$
      .pipe(take(1), takeUntilDestroyed(this.destroyRef))
      .subscribe(() => {
        this.store.loadTotalsSummary();
        this.store.loadCashFlow();
        this.store.loadRecentTransactions();
      });
  }

  protected updateCurrency(e: string) {
    this.store.accountsStore.updateSelectedCurrencyCode(e);
    this.store.loadTotalsSummary();
    this.store.loadCashFlow();
    this.store.loadRecentTransactions();
  }
}
