import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { BudgetMapper } from '../mappers';
import { CategoryMonthlyBudget, GroupMonthlyBudget } from '../models';

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
        p_month: month,
        p_currency_code: currencyCode,
        p_group_id: groupId,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromGroupMonthlyBudgetDto);
  }
}
