import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { DailyDataPoint, FinancialSummary } from '../models';

interface DailyDataPointDto {
  day: string;
  daily_income: number;
  daily_expense: number;
  running_balance: number;
}

interface FinancialSummaryDto {
  monthly_income: number;
  previous_monthly_income: number;
  monthly_expense: number;
  previous_monthly_expense: number;
  total_balance: number;
  previous_total_balance: number;
  income_transaction_count: number;
  expense_transaction_count: number;
  income_groups_count: number;
  expense_groups_count: number;
}

@Injectable({ providedIn: 'root' })
export class AnalyticsRepository {
  private readonly supabase = inject(SupabaseService);

  async getFinancialSummary(
    month: Date,
    currencyCode: string,
    accountIds: number[],
  ): Promise<FinancialSummary> {
    const { data, error } = await this.supabase.client.rpc(
      'get_analytics_financial_summary',
      {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
        p_account_ids: accountIds.length ? accountIds : null,
      },
    );

    if (error) {
      throw new Error(error.message);
    }

    const row = (data as FinancialSummaryDto[])[0];

    return {
      monthlyIncome: row.monthly_income,
      previousMonthlyIncome: row.previous_monthly_income,
      monthlyExpense: row.monthly_expense,
      previousMonthlyExpense: row.previous_monthly_expense,
      totalBalance: row.total_balance,
      previousTotalBalance: row.previous_total_balance,
      incomeTransactionCount: row.income_transaction_count,
      expenseTransactionCount: row.expense_transaction_count,
      incomeGroupsCount: row.income_groups_count,
      expenseGroupsCount: row.expense_groups_count,
    };
  }

  async getDailyOverview(
    month: Date,
    currencyCode: string,
    accountIds: number[],
  ): Promise<DailyDataPoint[]> {
    const { data, error } = await this.supabase.client.rpc(
      'get_daily_financial_overview_for_month',
      {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
        p_account_ids: accountIds.length ? accountIds : null,
      },
    );

    if (error) throw new Error(error.message);

    return (data as DailyDataPointDto[]).map((row) => ({
      day: row.day,
      dailyIncome: row.daily_income,
      dailyExpense: row.daily_expense,
      runningBalance: row.running_balance,
    }));
  }
}
