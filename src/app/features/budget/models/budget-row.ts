export interface BudgetCategoryRow {
  tempId: number;
  categoryId: number;
  plannedAmount: number;
  prevPlannedAmount: number;
  currentSpentAmount: number;
  prevSpentAmount: number;
}

export interface BudgetGroupRow {
  tempId: number;
  groupId: number;
  categories: BudgetCategoryRow[];
}
