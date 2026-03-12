import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import { WalletMapper } from '../mappers';
import { RegularAccount } from '../models';

@Injectable({
  providedIn: 'root',
})
export class WalletRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(WalletMapper);

  async getRegularAccounts(): Promise<RegularAccount[]> {
    const { data, error } = await this.supabase.client
      .from('regular_accounts_with_balance')
      .select();
    if (error) {
      throw new Error(error.message);
    }
    return data.map(this.mapper.fromRegularAccountDto);
  }
}
