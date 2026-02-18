import { inject, Injectable } from '@angular/core';
import { AccountsMapper } from '@core/mappers/accounts-mapper';
import { Account } from '@core/models/accounts';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class AccountsRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(AccountsMapper);

  async getAll(): Promise<Account[]> {
    const { data, error } = await this.supabase.client
      .from('my_accounts')
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromAccountDto);
  }
}
