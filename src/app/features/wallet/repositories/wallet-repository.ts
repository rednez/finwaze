import { inject, Injectable } from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';
import { WalletMapper } from '../mappers';
import {
  MonthlySummary,
  RegularAccount,
  TransactionCashFlowItem,
} from '../models';
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

  async getRegularAccountDetails(accountId: number): Promise<RegularAccount> {
    const { data, error } = await this.supabase.client
      .rpc('get_regular_account_with_balance', { p_account_id: accountId })
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromRegularAccountDto(data);
  }

  async deleteRegularAccount(accountId: number): Promise<boolean> {
    const { error: transactionsError } = await this.supabase.client
      .from('transactions')
      .delete()
      .eq('account_id', accountId)
      .eq('type', 'internal');
    if (transactionsError) {
      throw new Error(transactionsError.message);
    }

    const { error: accountsError } = await this.supabase.client
      .from('accounts')
      .delete()
      .eq('id', accountId);
    if (accountsError) {
      throw new Error(accountsError.message);
    }

    return true;
  }

  async updateRegularAccount({
    accountId,
    accountName,
    currencyId,
  }: {
    accountId: number;
    accountName: string;
    currencyId?: number;
  }): Promise<boolean> {
    const updateData: { name: string; currency_id?: number } = {
      name: accountName,
    };
    if (currencyId) {
      updateData.currency_id = currencyId;
    }

    const { error } = await this.supabase.client
      .from('accounts')
      .update(updateData)
      .eq('id', accountId);
    if (error) {
      throw new Error(error.message);
    }

    return true;
  }

  async adjustRegularAccountBalance(
    accountId: number,
    targetBalance: number,
  ): Promise<boolean> {
    const { error } = await this.supabase.client
      .rpc('adjust_account_balance', {
        p_account_id: accountId,
        p_target_balance: targetBalance,
        p_local_offset: dayjs(new Date()).format('Z'),
      })
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return true;
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

  async getMonthlySummary(
    month: Date,
    transactionCurrencyCode: string,
  ): Promise<MonthlySummary[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_transaction_amounts_by_group', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_currency_code: transactionCurrencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromMonthlySummaryDto);
  }

  async makeTransfer({
    fromAccountId,
    toAccountId,
    fromAmount,
    toAmount,
  }: {
    fromAccountId: number;
    toAccountId: number;
    fromAmount: number;
    toAmount?: number | null;
  }): Promise<void> {
    const { data, error } = await this.supabase.client
      .rpc('make_transfer', {
        p_from_account_id: fromAccountId,
        p_to_account_id: toAccountId,
        p_from_amount: fromAmount,
        p_to_amount: toAmount,
        p_local_offset: dayjs(new Date()).format('Z'),
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return;
  }
}
