import { Injectable } from '@angular/core';
import {
  MonthlyCashFlow,
  RecentMonthlyBudget,
  RecentSavingsGoal,
  TotalSummaries,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class DashboardMapper {
  fromTotalsSummaryDto(dto: {
    total_balance?: number;
    monthly_income?: number;
    monthly_expense?: number;
    previous_total_balance?: number;
    previous_monthly_income?: number;
    previous_monthly_expense?: number;
  }): TotalSummaries {
    return {
      totalBalance: dto.total_balance ?? 0,
      monthlyIncome: dto.monthly_income ?? 0,
      monthlyExpense: dto.monthly_expense ?? 0,
      previousMonthTotalBalance: dto.previous_total_balance ?? 0,
      previousMonthlyIncome: dto.previous_monthly_income ?? 0,
      previousMonthlyExpense: dto.previous_monthly_expense ?? 0,
    };
  }

  fromMonthlyCashFlowDto(dto: {
    month: string;
    total_income?: number;
    total_expense?: number;
  }): MonthlyCashFlow {
    return {
      month: new Date(dto.month),
      income: dto.total_income ?? 0,
      expense: dto.total_income ? Math.abs(dto.total_expense ?? 0) : 0,
    };
  }

  fromRecentSavingsGoalDto(dto: {
    id: number;
    name: string;
    amount: number;
    balance: number;
    currency_code: string;
  }): RecentSavingsGoal {
    return {
      id: dto.id,
      name: dto.name,
      targetAmount: dto.amount,
      currentAmount: dto.balance,
      currency: dto.currency_code,
    };
  }

  fromRecentMonthlyBudgetDto(dto: {
    category_name: string;
    total_budget: number;
  }): RecentMonthlyBudget {
    return {
      name: dto.category_name,
      amount: dto.total_budget,
    };
  }
}
