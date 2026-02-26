import { inject, Injectable } from '@angular/core';
import { CategoriesMapper } from '@core/mappers/categories-mapper';
import { Category } from '@core/models/categories';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class CategoriesRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(CategoriesMapper);

  async getCategories(): Promise<Category[]> {
    const { data, error } = await this.supabase.client
      .from('categories')
      .select(`id, name, groups( id, name )`)
      .eq('is_system', false);

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromCategoryDto);
  }
}
