import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { BudgetState } from '../../services/budget-state';
import { BudgetCard } from '../../ui/budget-card/budget-card';
import { BudgetFilters } from '../../ui/budget-filters';
import { BudgetMostExpensesCard } from '../../ui/budget-most-expenses-card';
import { MonthlySummaryCard } from '../../ui/monthly-summary-card';

@Component({
  selector: 'app-budget',
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
  private readonly router = inject(Router);
  private readonly budgetState = inject(BudgetState);

  protected readonly groups = signal([
    {
      id: 1,
      name: 'Life',
      budgetAmount: 12000.32,
      spentAmount: 11090.98,
      currency: 'UAH',
      categoriesCount: 4,
    },
    {
      id: 11,
      name: 'Life',
      budgetAmount: 3200.32,
      spentAmount: 3000.98,
      currency: 'USD',
      categoriesCount: 6,
    },
    {
      id: 2,
      name: 'Medicine',
      budgetAmount: 500,
      spentAmount: 450,
      currency: 'UAH',
      categoriesCount: 2,
    },
    {
      id: 3,
      name: 'Entertainment',
      budgetAmount: 2300,
      spentAmount: 1200.4,
      currency: 'USD',
      categoriesCount: 9,
    },
    {
      id: 4,
      name: 'Sport and Movies',
      budgetAmount: 1500,
      spentAmount: 450,
      currency: 'USD',
      categoriesCount: 12,
    },
    {
      id: 5,
      name: 'Other',
      budgetAmount: 22500,
      spentAmount: 82321.76,
      currency: 'USD',
      categoriesCount: 5,
    },
  ]);

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
    this.budgetState.selectedGroupName.set('');
  }

  gotoBudgetByGroup(id: number, name: string) {
    this.budgetState.selectedCurrency.set('USD');
    this.budgetState.selectedGroupName.set(name);

    this.router.navigate([`/budget/groups/${id}`]);
  }
}
