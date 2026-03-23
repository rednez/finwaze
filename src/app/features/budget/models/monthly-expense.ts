export interface MonthlyExpenseByGroupDto {
  group_id: number;
  group_name: string;
  selected_month_amount: number;
  previous_month_amount: number;
}

export interface MonthlyExpenseByCategoryDto {
  category_id: number;
  category_name: string;
  selected_month_amount: number;
  previous_month_amount: number;
}

export interface MonthlyExpense {
  id: number;
  name: string;
  selectedMonthAmount: number;
  previousMonthAmount: number;
}
