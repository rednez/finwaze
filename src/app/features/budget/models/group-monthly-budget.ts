export interface GroupMonthlyBudgetDto {
  group_id: number;
  group_name: string;
  planned_amount: number;
  spent_amount: number;
  is_unplanned: boolean;
  categories_count: number;
}

export interface GroupMonthlyBudget {
  id: number;
  name: string;
  plannedAmount: number;
  spentAmount: number;
  isUnplanned: boolean;
  categoriesCount: number;
}
