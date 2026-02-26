import { inject, Injectable } from '@angular/core';
import { TransactionsMapper } from '@core/mappers/transactions-mapper';
import { Transaction } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';

@Injectable({
  providedIn: 'root',
})
export class TransactionsRepository {
  private readonly mapper = inject(TransactionsMapper);
  private readonly supabase = inject(SupabaseService);

  async getFilteredTransactions(filters: {
    month: Date;
    categoryIds: number[] | null;
    transactionCurrencyCode: string | null;
  }): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_filtered_transactions', {
        p_month: dayjs(filters.month).format('YYYY-MM-DD'),
        p_category_ids: filters.categoryIds,
        p_transaction_currency_codes: filters.transactionCurrencyCode
          ? [filters.transactionCurrencyCode]
          : null,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromTransactionDto);
  }
}
