import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import {
  DailyDataPoint,
  FinancialSummary,
  GroupAmount,
  MonthlyBudgetExpense,
} from '../models';

interface DailyDataPointDto {
  day: string;
  daily_income: number;
  daily_expense: number;
  running_balance: number;
}

interface GroupAmountDto {
  group_id: number;
  group_name: string;
  income_amount: number;
  expense_amount: number;
}

interface BudgetByGroupDto {
  group_id: number;
  group_name: string;
  planned_amount: number;
}

interface YearlyBudgetExpenseDto {
  month: string;
  budget_amount: number;
  expense_amount: number;
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

  async getGroupsStatistics(
    month: Date,
    currencyCode: string,
    accountIds: number[],
  ): Promise<{
    incomeByGroups: GroupAmount[];
    expenseByGroups: GroupAmount[];
    budgetByGroups: GroupAmount[];
  }> {
    const formattedMonth = dayjs(month).format('YYYY-MM-DD');

    const [amountsResult, budgetsResult] = await Promise.all([
      this.supabase.client.rpc('get_analytics_amounts_by_groups', {
        p_month: formattedMonth,
        p_currency_code: currencyCode,
        p_account_ids: accountIds.length ? accountIds : null,
      }),
      this.supabase.client.rpc('get_monthly_budgets_by_groups', {
        p_month: formattedMonth,
        p_currency_code: currencyCode,
      }),
    ]);

    if (amountsResult.error) throw new Error(amountsResult.error.message);
    if (budgetsResult.error) throw new Error(budgetsResult.error.message);

    const amounts = amountsResult.data as GroupAmountDto[];
    const budgets = budgetsResult.data as BudgetByGroupDto[];

    return {
      incomeByGroups: amounts.map((row) => ({
        groupId: row.group_id,
        groupName: row.group_name,
        amount: row.income_amount,
      })),
      expenseByGroups: amounts.map((row) => ({
        groupId: row.group_id,
        groupName: row.group_name,
        amount: row.expense_amount,
      })),
      budgetByGroups: budgets.map((row) => ({
        groupId: row.group_id,
        groupName: row.group_name,
        amount: row.planned_amount,
      })),
    };
  }

  async getYearlyBudgetsVsExpenses(
    year: number,
    currencyCode: string,
  ): Promise<MonthlyBudgetExpense[]> {
    const { data, error } = await this.supabase.client.rpc(
      'get_yearly_budgets_vs_expenses',
      {
        p_year: year,
        p_currency_code: currencyCode,
      },
    );

    if (error) throw new Error(error.message);

    return (data as YearlyBudgetExpenseDto[]).map((row) => ({
      month: row.month,
      budgetAmount: row.budget_amount,
      expenseAmount: row.expense_amount,
    }));
  }
}
