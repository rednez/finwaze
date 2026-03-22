import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { BudgetMapper } from '../mappers';
import {
  CategoryMonthlyBudget,
  GroupMonthlyBudget,
  MonthlyBudgetTotals,
  MonthlyBudgetTotalsDto,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class BudgetRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(BudgetMapper);

  async getGroupsMonthlyBudgets({
    month,
    currencyCode,
  }: {
    month: Date;
    currencyCode: string;
  }): Promise<GroupMonthlyBudget[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_budgets_by_groups', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromGroupMonthlyBudgetDto);
  }

  async getCategoriesMonthlyBudgets({
    month,
    currencyCode,
    groupId,
  }: {
    month: Date;
    currencyCode: string;
    groupId: number;
  }): Promise<CategoryMonthlyBudget[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_budgets_by_categories', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
        p_group_id: groupId,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromGroupMonthlyBudgetDto);
  }

  async getMonthlyBudgetTotals({
    month,
    currencyCode,
  }: {
    month: Date;
    currencyCode: string;
  }): Promise<MonthlyBudgetTotals> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_budget_totals', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
      })
      .select()
      .single<MonthlyBudgetTotalsDto>();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromMonthlyBudgetTotalsDto(data);
  }
}
