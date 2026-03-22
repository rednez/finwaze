export interface RegularAccountDto {
  id: number;
  name: string;
  currency_id: number;
  currency_code: string;
  balance: number;
  can_delete: boolean;
}

export interface TransactionCashFlowItemDto {
  day: string;
  total_expense: number;
  total_income: number;
}

export interface MonthlySummaryDto {
  group_name: string;
  total_expense: number;
  total_income: number;
}
