export type GoalStatus = 'notStarted' | 'inProgress' | 'done' | 'cancelled';

export interface SavingsGoal {
  id: number;
  name: string;
  targetAmount: number;
  accumulatedAmount: number;
  targetDate: Date;
  currencyCode: string;
  status: GoalStatus;
}
