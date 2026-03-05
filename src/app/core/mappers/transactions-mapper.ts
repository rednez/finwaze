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
      account_id,
      account_name,
      charged_amount,
      charged_currency_code,
      exchange_rate,
      type,
      category_id,
      category_name,
      group_id,
      group_name,
      comment,
    } = dto;

    return {
      id,
      account: { id: account_id, name: account_name },
      transactedAt: new Date(transacted_at),
      localOffset: this.parseLocalOffset(local_offset),
      transactionAmount: transaction_amount,
      transactionCurrency: transaction_currency_code,
      chargedAmount: charged_amount,
      chargedCurrency: charged_currency_code,
      exchangeRate: exchange_rate,
      type,
      group: { id: group_id, name: group_name },
      category: { id: category_id, name: category_name },
      comment,
    };
  };

  fromTransactionDetailsDto = (dto: any): Transaction => {
    const {
      id,
      transacted_at,
      local_offset,
      transaction_amount,
      charged_amount,
      type,
      comment,
      account,
      transaction_currency,
      charged_currency,
      category,
    } = dto;

    return {
      id,
      account: { id: account.id, name: account.name },
      transactedAt: new Date(transacted_at),
      localOffset: this.parseLocalOffset(local_offset),
      transactionAmount: transaction_amount,
      transactionCurrency: transaction_currency.code,
      chargedAmount: charged_amount,
      chargedCurrency: charged_currency.code,
      exchangeRate: charged_amount / transaction_amount,
      type,
      group: { id: category.group.id, name: category.group.name },
      category: { id: category.id, name: category.name },
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
