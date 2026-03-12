import { inject, Injectable } from '@angular/core';
import { CategoriesMapper } from '@core/mappers/categories-mapper';
import { Category, Group } from '@core/models/categories';
import { TransactionType } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import { GroupsAndCategoriesMapper } from '../mappers';
import { GroupWithCategories } from '../models';

@Injectable({
  providedIn: 'root',
})
export class GroupsAndCategoriesRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(GroupsAndCategoriesMapper);
  private readonly coreMapper = inject(CategoriesMapper);

  async getGroups(): Promise<GroupWithCategories[]> {
    const { data, error } = await this.supabase.client
      .from('groups_with_categories_tx_counts')
      .select();
    if (error) {
      throw new Error(error.message);
    }
    return data.map(this.mapper.fromGroupWithCategoriesDto);
  }

  async createGroup(
    name: string,
    transactionType: TransactionType,
  ): Promise<Group> {
    const { error, data } = await this.supabase.client
      .from('groups')
      .insert({ name, transaction_type: transactionType })
      .select('id, name, transaction_type')
      .single();
    if (error) {
      throw new Error(error.message);
    }
    return this.coreMapper.fromGroupDto(data);
  }

  async renameGroup(id: number, name: string): Promise<void> {
    const { error } = await this.supabase.client
      .from('groups')
      .update({ name })
      .eq('id', id);
    if (error) {
      throw new Error(error.message);
    }
    return;
  }

  async deleteGroup(id: number): Promise<{ hasGroups: boolean }> {
    const { error } = await this.supabase.client
      .from('groups')
      .delete()
      .eq('id', id);
    const { count } = await this.supabase.client
      .from('groups')
      .select('id', { head: true, count: 'exact' });

    if (error) {
      throw new Error(error.message);
    }
    return { hasGroups: !!count && count > 0 };
  }

  async createCategory(name: string, groupId: number): Promise<Category> {
    const { error, data } = await this.supabase.client
      .from('categories')
      .insert({ name, group_id: groupId })
      .select('id, name, group_id')
      .single();
    if (error) {
      throw new Error(error.message);
    }
    return this.coreMapper.fromCategoryDto(data);
  }

  async renameCategory(id: number, name: string): Promise<void> {
    const { error } = await this.supabase.client
      .from('categories')
      .update({ name })
      .eq('id', id);
    if (error) {
      throw new Error(error.message);
    }
    return;
  }

  async deleteCategory(id: number): Promise<void> {
    const { error } = await this.supabase.client
      .from('categories')
      .delete()
      .eq('id', id);
    if (error) {
      throw new Error(error.message);
    }
    return;
  }
}
