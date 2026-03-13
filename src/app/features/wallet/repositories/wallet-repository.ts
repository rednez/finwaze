import { inject, Injectable } from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { WalletMapper } from '../mappers';
import { RegularAccount, TransactionCashFlowItem } from '../models';
import { TransactionsMapper } from '@core/mappers/transactions-mapper';

@Injectable({
  providedIn: 'root',
})
export class WalletRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(WalletMapper);
  private readonly transactionsMapper = inject(TransactionsMapper);

  async getRegularAccounts(): Promise<RegularAccount[]> {
    const { data, error } = await this.supabase.client
      .from('regular_accounts_with_balance')
      .select();
    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromRegularAccountDto);
  }

  async getDailyTransactionCashFlow(
    currencyCode: string,
    month: Date,
  ): Promise<TransactionCashFlowItem[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_daily_transactions_cash_flow_for_month', {
        p_currency_code: currencyCode,
        p_month: dayjs(month).format('YYYY-MM-DD'),
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromDailyTransactionCashFlowItemDto);
  }

  async getRecentTransactions(
    transactionCurrencyCode: string,
  ): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_filtered_transactions', {
        p_transaction_currency_codes: [transactionCurrencyCode],
        p_page_size: 3,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.transactionsMapper.fromTransactionDto);
  }
}
