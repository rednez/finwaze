import { Injectable } from '@angular/core';
import { Transaction } from '@core/models/transactions';

@Injectable({
  providedIn: 'root',
})
export class TransactionsMapper {
  fromTransactionDto = (dto: any): Transaction => {
    const {
      id,
      transacted_at,
      local_offset,
      transaction_amount,
      transaction_currency_code,
      account_name,
      account_amount,
      account_currency_code,
      exchange_rate,
      type,
      category_name,
      group_name,
      comment,
    } = dto;

    return {
      id,
      accountName: account_name,
      transactedAt: new Date(transacted_at),
      localOffset: this.parseLocalOffset(local_offset),
      transactionAmount: transaction_amount,
      transactionCurrency: transaction_currency_code,
      chargedAmount: account_amount,
      chargedCurrency: account_currency_code,
      exchangeRate: exchange_rate,
      type,
      groupName: group_name,
      categoryName: category_name,
      comment,
    };
  };

  private parseLocalOffset = (offset: string): string => {
    const normalized = offset.trim();

    if (!normalized) {
      return '+00:00';
    }

    const withSign =
      normalized.startsWith('+') || normalized.startsWith('-')
        ? normalized
        : `+${normalized}`;

    return withSign.replace(/:00$/, '');
  };
}
