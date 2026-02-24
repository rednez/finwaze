import { Injectable } from '@angular/core';
import { MonthlyCashFlow, RecentSavingsGoal, TotalSummaries } from '../models';

@Injectable({
  providedIn: 'root',
})
export class DashboardMapper {
  fromTotalsSummaryDto(dto: any): TotalSummaries {
    return {
      totalBalance: dto.total_balance ?? 0,
      monthlyIncome: dto.monthly_income ?? 0,
      monthlyExpense: dto.monthly_expense ?? 0,
      previousMonthTotalBalance: dto.previous_total_balance ?? 0,
      previousMonthlyIncome: dto.previous_monthly_income ?? 0,
      previousMonthlyExpense: dto.previous_monthly_expense ?? 0,
    };
  }

  fromMonthlyCashFlowDto(dto: any): MonthlyCashFlow {
    return {
      month: new Date(dto.month),
      income: dto.total_income ?? 0,
      expense: Math.abs(dto.total_expense) ?? 0,
    };
  }

  fromRecentSavingsGoalDto(dto: any): RecentSavingsGoal {
    return {
      id: dto.id,
      name: dto.name,
      targetAmount: dto.amount,
      currentAmount: dto.balance,
      currency: dto.currency_code,
    };
  }
}
