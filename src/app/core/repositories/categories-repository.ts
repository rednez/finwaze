import { inject, Injectable } from '@angular/core';
import { CategoriesMapper } from '@core/mappers/categories-mapper';
import { Category, Group } from '@core/models/categories';
import { TransactionType } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class CategoriesRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(CategoriesMapper);

  async getGroups(): Promise<Group[]> {
    const { data, error } = await this.supabase.client
      .from('groups')
      .select(`id, name, transaction_type`)
      .eq('is_system', false);

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromGroupDto);
  }

  async getCategories(): Promise<Category[]> {
    const { data, error } = await this.supabase.client
      .from('categories')
      .select(`id, name, group_id`)
      .eq('is_system', false);

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromCategoryDto);
  }

  async createGroup(
    name: string,
    transactionType: TransactionType,
  ): Promise<Group> {
    const { data, error } = await this.supabase.client
      .from('groups')
      .insert({ name, transaction_type: transactionType })
      .select('id, name, transaction_type')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromGroupDto(data);
  }

  async createCategory(name: string, groupId: number): Promise<Category> {
    const { data, error } = await this.supabase.client
      .from('categories')
      .insert({ name, group_id: groupId })
      .select('id, name, group_id')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromCategoryDto(data);
  }
}
