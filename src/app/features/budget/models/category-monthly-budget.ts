export interface CategoryMonthlyBudgetDto {
  category_id: number;
  category_name: string;
  planned_amount: number;
  spent_amount: number;
  is_unplanned: boolean;
}

export interface CategoryMonthlyBudget {
  id: number;
  name: string;
  plannedAmount: number;
  spentAmount: number;
  isUnplanned: boolean;
}
