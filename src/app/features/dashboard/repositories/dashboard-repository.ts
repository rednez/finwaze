import { inject, Injectable } from '@angular/core';
import { SavingsGoalsMapper } from '@core/mappers/savings-goals-mapper';
import { TransactionsMapper } from '@core/mappers/transactions-mapper';
import { SavingsGoal } from '@core/models/savings-goal';
import { Transaction } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import { DashboardMapper } from '../mappers';
import {
  MonthlyCashFlow,
  RecentMonthlyBudget,
  TotalSummaries,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class DashboardRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(DashboardMapper);
  private readonly transactionsMapper = inject(TransactionsMapper);
  private readonly savingsGoalsMapper = inject(SavingsGoalsMapper);

  async getTotals(currencyCode: string): Promise<TotalSummaries> {
    const { data, error } = await this.supabase.client
      .rpc('get_dashboard_totals', {
        p_currency_code: currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromTotalsSummaryDto(data[0]);
  }

  async getMonthlyCashFlow(
    currencyCode: string,
    months: number,
  ): Promise<MonthlyCashFlow[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_charged_cash_flow', {
        p_currency_code: currencyCode,
        p_months: months,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromMonthlyCashFlowDto);
  }

  async getRecentTransactions(): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_recent_transactions', {
        p_limit: 3,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.transactionsMapper.fromTransactionDto);
  }

  async getRecentSavingsGoals(): Promise<SavingsGoal[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_savings_goals', {
        p_limit: 3,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.savingsGoalsMapper.fromSavingsGoalDto);
  }

  async getRecentMonthlyBudgets(
    currencyCode: string,
  ): Promise<RecentMonthlyBudget[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_current_month_budgets_by_category', {
        p_currency_code: currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromRecentMonthlyBudgetDto);
  }
}
