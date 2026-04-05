import { inject, Injectable } from '@angular/core';
import { CategoriesMapper } from '@core/mappers/categories-mapper';
import { Group } from '@core/models/categories';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { BudgetMapper } from '../mappers';
import {
  CategoryMonthlyBudget,
  GroupMonthlyBudget,
  MonthlyBudgetDetailedDto,
  MonthlyBudgetTotals,
  MonthlyBudgetTotalsDto,
  MonthlyExpense,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class BudgetRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(BudgetMapper);
  private readonly categoriesMapper = inject(CategoriesMapper);

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

    return data.map(this.mapper.fromCategoryMonthlyBudgetDto);
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

  async getMonthlyBudgetTotalsByGroup({
    month,
    currencyCode,
    groupId,
  }: {
    month: Date;
    currencyCode: string;
    groupId: number;
  }): Promise<MonthlyBudgetTotals> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_budget_totals_by_group', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
        p_group_id: groupId,
      })
      .select()
      .single<MonthlyBudgetTotalsDto>();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromMonthlyBudgetTotalsDto(data);
  }

  async getMonthlyExpensesByGroups({
    month,
    currencyCode,
  }: {
    month: Date;
    currencyCode: string;
  }): Promise<MonthlyExpense[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_expenses_by_groups', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromMonthlyExpenseByGroupDto);
  }

  async getMonthlyExpensesByCategories({
    month,
    currencyCode,
    groupId,
  }: {
    month: Date;
    currencyCode: string;
    groupId: number;
  }): Promise<MonthlyExpense[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_expenses_by_categories', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: currencyCode,
        p_group_id: groupId,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromMonthlyExpenseByCategoryDto);
  }

  async getDetailedMonthlyBudgets({
    month,
    currencyCode,
  }: {
    month: string;
    currencyCode: string;
  }): Promise<MonthlyBudgetDetailedDto[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_budgets_detailed', {
        p_month: month,
        p_currency_code: currencyCode,
      })
      .select();

    if (error) throw new Error(error.message);
    return data as MonthlyBudgetDetailedDto[];
  }

  async generateBudgetsFromPrevious({
    month,
    currencyCode,
  }: {
    month: string;
    currencyCode: string;
  }): Promise<MonthlyBudgetDetailedDto[]> {
    const { data, error } = await this.supabase.client
      .rpc('generate_monthly_budgets_from_previous', {
        p_month: month,
        p_currency_code: currencyCode,
      })
      .select();

    if (error) throw new Error(error.message);
    return data as MonthlyBudgetDetailedDto[];
  }

  async upsertMonthlyBudgets({
    month,
    currencyCode,
    categories,
  }: {
    month: string;
    currencyCode: string;
    categories: { category_id: number; planned_amount: number }[];
  }): Promise<void> {
    const { error } = await this.supabase.client.rpc('upsert_monthly_budgets', {
      p_month: month,
      p_currency_code: currencyCode,
      p_categories: categories,
    });

    if (error) throw new Error(error.message);
  }

  async getCategoryBudgetStats({
    month,
    currencyCode,
    categoryId,
  }: {
    month: string;
    currencyCode: string;
    categoryId: number;
  }): Promise<{
    prevPlannedAmount: number;
    currentSpentAmount: number;
    prevSpentAmount: number;
  }> {
    const { data, error } = await this.supabase.client
      .rpc('get_category_budget_stats', {
        p_month: month,
        p_currency_code: currencyCode,
        p_category_id: categoryId,
      })
      .select()
      .single<{
        previous_planned_amount: number;
        spent_amount: number;
        previous_spent_amount: number;
      }>();

    if (error) throw new Error(error.message);

    return {
      prevPlannedAmount: data.previous_planned_amount,
      currentSpentAmount: data.spent_amount,
      prevSpentAmount: data.previous_spent_amount,
    };
  }

  async getGroup(groupId: number): Promise<Group> {
    const { data, error } = await this.supabase.client
      .from('groups')
      .select()
      .eq('id', groupId)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return this.categoriesMapper.fromGroupDto(data);
  }
}
