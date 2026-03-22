import { inject, Injectable } from '@angular/core';
import { AccountsMapper } from '@core/mappers/accounts-mapper';
import { Account, AccountDto } from '@core/models/accounts';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class AccountsRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(AccountsMapper);

  async getAll(): Promise<Account[]> {
    const { data, error } = await this.supabase.client
      .from('accounts')
      .select(`id, name, currencies(code)`)
      .eq('type', 'regular')
      .overrideTypes<AccountDto[]>();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromAccountDto);
  }

  async create(accountName: string, currencyId: number): Promise<Account> {
    const { data, error } = await this.supabase.client
      .from('accounts')
      .insert([{ name: accountName, currency_id: currencyId }])
      .select(`id, name, currencies(code)`)
      .overrideTypes<AccountDto[]>();
    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromAccountDto(data[0]);
  }
}
