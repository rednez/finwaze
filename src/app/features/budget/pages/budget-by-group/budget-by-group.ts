import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { BudgetsByGroupStore, BudgetStore } from '../../stores';
import { BudgetCard } from '../../ui/budget-card';
import { BudgetMostExpensesCard } from '../../ui/budget-most-expenses-card';
import { MonthlySummaryCard } from '../../ui/monthly-summary-card';
import { ActivatedRoute } from '@angular/router';

@Component({
  imports: [BudgetCard, MonthlySummaryCard, BudgetMostExpensesCard],
  templateUrl: './budget-by-group.html',
  host: {
    class: 'flex flex-col gap-4 md:flex-row md:flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [BudgetsByGroupStore],
})
export class BudgetByGroup {
  protected readonly budgetsByGroupStore = inject(BudgetsByGroupStore);
  protected readonly budgetStore = inject(BudgetStore);
  private readonly route = inject(ActivatedRoute);

  constructor() {
    this.loadData();
  }

  private async loadData() {
    const groupId = Number(this.route.snapshot.paramMap.get('id'));

    const { error } = await this.budgetStore.loadGroup(groupId);

    if (!error) {
      this.budgetsByGroupStore.loadMonthlyBudgets();
      this.budgetsByGroupStore.loadMonthlyBudgetTotals();
      this.budgetsByGroupStore.loadMonthlyExpenses();
    }
  }
}
