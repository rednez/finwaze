import { Injectable } from '@angular/core';
import {
  MonthlySummary,
  MonthlySummaryDto,
  RegularAccount,
  RegularAccountDto,
  TransactionCashFlowItem,
  TransactionCashFlowItemDto,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class WalletMapper {
  fromRegularAccountDto(dto: RegularAccountDto): RegularAccount {
    return {
      id: dto.id,
      name: dto.name,
      currency: { id: dto.currency_id, code: dto.currency_code },
      balance: dto.balance,
      canDelete: dto.can_delete,
    };
  }

  fromDailyTransactionCashFlowItemDto(
    dto: TransactionCashFlowItemDto,
  ): TransactionCashFlowItem {
    return {
      label: dto.day,
      expense: Math.abs(dto.total_expense),
      income: dto.total_income,
    };
  }

  fromMonthlySummaryDto(dto: MonthlySummaryDto): MonthlySummary {
    return {
      groupName: dto.group_name,
      totalExpense: Math.abs(dto.total_expense),
      totalIncome: dto.total_income,
    };
  }
}
