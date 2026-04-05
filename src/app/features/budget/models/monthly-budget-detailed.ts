export interface MonthlyBudgetDetailedDto {
  category_id: number;
  category_name: string;
  group_id: number;
  group_name: string;
  planned_amount: number;
  previous_planned_amount: number;
  spent_amount: number;
  previous_spent_amount: number;
  is_unplanned: boolean;
}
