import { inject, Injectable } from '@angular/core';
import { CurrenciesMapper } from '@core/mappers/currencies-mapper';
import { Currency } from '@core/models/currencies';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class CurrenciesRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(CurrenciesMapper);

  async getAll(): Promise<Currency[]> {
    const { data, error } = await this.supabase.client
      .from('currencies')
      .select('code, name, country_name');

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromCurrencyDto);
  }
}
