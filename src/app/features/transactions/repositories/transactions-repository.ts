import { inject, Injectable } from '@angular/core';
import { TransactionsMapper } from '@core/mappers/transactions-mapper';
import { Transaction, TransactionType } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';

interface ExpenseTransactionData {
  transactedAt: Date;
  accountId: number;
  categoryId: number;
  transactionAmount: number;
  transactionCurrencyId: number;
  chargedAmount: number;
  comment: string;
}

interface IncomeTransactionData {
  transactedAt: Date;
  accountId: number;
  categoryId: number;
  amount: number;
  currencyId: number;
  comment: string;
}

const transactionDetailsSelect = `
        id,
        transacted_at,
        local_offset,
        transaction_amount,
        charged_amount,
        type,
        comment,
        account:accounts!transactions_account_id_fkey(id, name),
        transaction_currency:currencies!transactions_transaction_currency_id_fkey(id, code),
        charged_currency:currencies!transactions_charged_currency_id_fkey(id, code),
        category:categories!transactions_category_id_fkey(id, name,
          group:groups!categories_group_id_fkey(id, name)
        )
         `;

@Injectable({
  providedIn: 'root',
})
export class TransactionsRepository {
  private readonly mapper = inject(TransactionsMapper);
  private readonly supabase = inject(SupabaseService);

  async getFilteredTransactions(filters: {
    month: Date;
    transactionType: TransactionType | null;
    categoryIds: number[] | null;
    transactionCurrencyCode: string | null;
  }): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_filtered_transactions', {
        p_month: dayjs(filters.month).format('YYYY-MM-DD'),
        p_transaction_type: filters.transactionType,
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

  async getTransactionDetails(transactionId: number): Promise<Transaction> {
    const { error, data } = await this.supabase.client
      .from('transactions')
      .select(transactionDetailsSelect)
      .eq('id', transactionId)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromTransactionDetailsDto(data);
  }

  async createExpenseTransaction(
    transactionData: ExpenseTransactionData,
  ): Promise<void> {
    const { error } = await this.supabase.client
      .from('transactions')
      .insert({
        type: 'expense',
        transacted_at: transactionData.transactedAt,
        local_offset: dayjs(transactionData.transactedAt).format('Z'),
        comment: transactionData.comment,
        account_id: transactionData.accountId,
        category_id: transactionData.categoryId,
        transaction_amount: transactionData.transactionAmount,
        transaction_currency_id: transactionData.transactionCurrencyId,
        charged_amount: transactionData.chargedAmount,
      })
      .select(transactionDetailsSelect)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return;
  }

  async createIncomeTransaction(
    transactionData: IncomeTransactionData,
  ): Promise<void> {
    const { error } = await this.supabase.client
      .from('transactions')
      .insert({
        type: 'income',
        transacted_at: transactionData.transactedAt,
        local_offset: dayjs(transactionData.transactedAt).format('Z'),
        comment: transactionData.comment,
        account_id: transactionData.accountId,
        category_id: transactionData.categoryId,
        transaction_amount: transactionData.amount,
        transaction_currency_id: transactionData.currencyId,
        charged_amount: transactionData.amount,
      })
      .select(transactionDetailsSelect)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return;
  }

  async updateExpenseTransaction(
    transactionId: number,
    transactionData: Partial<ExpenseTransactionData>,
  ): Promise<void> {
    const { error } = await this.supabase.client
      .from('transactions')
      .update({
        transacted_at: transactionData.transactedAt,
        local_offset: transactionData.transactedAt
          ? dayjs(transactionData.transactedAt).format('Z')
          : undefined,
        comment: transactionData.comment,
        account_id: transactionData.accountId,
        category_id: transactionData.categoryId,
        transaction_amount: transactionData.transactionAmount,
        transaction_currency_id: transactionData.transactionCurrencyId,
        charged_amount: transactionData.chargedAmount,
      })
      .eq('id', transactionId)
      .select(transactionDetailsSelect)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return;
  }

  async updateIncomeTransaction(
    transactionId: number,
    transactionData: Partial<IncomeTransactionData>,
  ): Promise<void> {
    const { error } = await this.supabase.client
      .from('transactions')
      .update({
        transacted_at: transactionData.transactedAt,
        local_offset: transactionData.transactedAt
          ? dayjs(transactionData.transactedAt).format('Z')
          : undefined,
        comment: transactionData.comment,
        account_id: transactionData.accountId,
        category_id: transactionData.categoryId,
        transaction_amount: transactionData.amount,
        transaction_currency_id: transactionData.currencyId,
        charged_amount: transactionData.amount,
      })
      .eq('id', transactionId)
      .select(transactionDetailsSelect)
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return;
  }

  async deleteTransaction(transactionId: number): Promise<void> {
    const { error } = await this.supabase.client
      .from('transactions')
      .delete()
      .eq('id', transactionId);

    if (error) {
      throw new Error(error.message);
    }

    return;
  }
}
