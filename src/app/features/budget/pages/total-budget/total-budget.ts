import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { EmptyState } from '@shared/ui/empty-state';
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
    EmptyState,
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

  constructor() {
    this.budgetStore.resetSelectedGroup();
    this.loadData();
  }

  protected gotoBudgetByGroup(id: number) {
    this.router.navigate([`/budget/groups/${id}`]);
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
    this.totalBudgetStore.loadMonthlyBudgets();
    this.totalBudgetStore.loadMonthlyBudgetTotals();
    this.totalBudgetStore.loadMonthlyExpenses();
  }
}
