import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import dayjs from 'dayjs';
import { ButtonModule } from 'primeng/button';
import { BudgetStatus } from '../../models';
import { BudgetStore, TotalBudgetStore } from '../../stores';
import { BudgetCard } from '../../ui/budget-card/budget-card';
import { BudgetFilters } from '../../ui/budget-filters';
import { BudgetMostExpensesCard } from '../../ui/budget-most-expenses-card';
import { MonthlySummaryCard } from '../../ui/monthly-summary-card';

@Component({
  imports: [
    BudgetCard,
    BudgetFilters,
    ButtonModule,
    MonthlySummaryCard,
    BudgetMostExpensesCard,
  ],
  templateUrl: './total-budget.html',
  host: {
    class: 'flex flex-col gap-4 md:flex-row md:flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TotalBudget {
  protected readonly budgetStore = inject(BudgetStore);
  protected readonly totalBudgetStore = inject(TotalBudgetStore);
  protected readonly accountsStore = inject(AccountsStore);
  private readonly router = inject(Router);

  protected readonly mostExpenses = signal([
    {
      id: 1,
      name: 'Food',
      currentAmount: 1200.4,
      previousPeriodAmount: 1000,
      currency: 'USD',
    },
    {
      id: 2,
      name: 'Medicine',
      currentAmount: 500,
      previousPeriodAmount: 1100,
      currency: 'USD',
    },
    {
      id: 3,
      name: 'Entertainment',
      currentAmount: 500,
      previousPeriodAmount: 800,
      currency: 'USD',
    },
    {
      id: 4,
      name: 'Sport and Movies',
      currentAmount: 450,
      previousPeriodAmount: 1500,
      currency: 'USD',
    },
    {
      id: 5,
      name: 'Other',
      currentAmount: 700,
      previousPeriodAmount: 750,
      currency: 'USD',
    },
    {
      id: 6,
      name: 'Other',
      currentAmount: 300,
      previousPeriodAmount: 290,
      currency: 'USD',
    },
    {
      id: 7,
      name: 'Other',
      currentAmount: 500,
      previousPeriodAmount: 600,
      currency: 'USD',
    },
  ]);

  constructor() {
    this.loadData();
  }

  protected gotoBudgetByGroup(id: number, name: string) {
    // TODO
    console.log({ id, name });

    // this.budgetState.selectedCurrency.set('USD');
    // this.budgetState.selectedGroupName.set(name);
    // this.router.navigate([`/budget/groups/${id}`]);
  }

  protected gotoCreateBudget() {
    this.router.navigate(['budget', 'create']);
  }

  protected onMonthChanged($event: Date) {
    if (!dayjs($event).isSame(this.budgetStore.month(), 'month')) {
      this.budgetStore.updateMonth($event);
      this.loadData();
    }
  }

  protected onCurrencyChanged($event: string) {
    if (this.budgetStore.currencyCode() !== $event) {
      this.budgetStore.updateCurrencyCode($event);
      this.loadData();
    }
  }

  protected onStatusChanged($event: string) {
    this.totalBudgetStore.updateStatus($event as 'all' | BudgetStatus);
  }

  onSelectedGroupsIdsChanged($event: number[]) {
    this.totalBudgetStore.updateSelectedGroupsIds($event);
  }

  private loadData() {
    this.totalBudgetStore.loadGroupsMonthlyBudgets();
    this.totalBudgetStore.loadMonthlyBudgetTotals();
  }
}
