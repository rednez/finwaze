import { Injectable } from '@angular/core';
import {
  MonthlySummary,
  RegularAccount,
  TransactionCashFlowItem,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class WalletMapper {
  fromRegularAccountDto(dto: any): RegularAccount {
    return {
      id: dto.id,
      name: dto.name,
      currencyCode: dto.currency_code,
      balance: dto.balance,
    };
  }

  fromDailyTransactionCashFlowItemDto(dto: any): TransactionCashFlowItem {
    return {
      label: dto.day,
      expense: Math.abs(dto.total_expense),
      income: dto.total_income,
    };
  }

  fromMonthlySummaryDto(dto: any): MonthlySummary {
    return {
      groupName: dto.group_name,
      totalExpense: Math.abs(dto.total_expense),
      totalIncome: dto.total_income,
    };
  }
}
