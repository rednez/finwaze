export type GoalStatus = 'notStarted' | 'inProgress' | 'done' | 'cancelled';

// TODO: ?
export interface Goal {
  id: number;
  name: string;
  targetAmount: number;
  savingAmount: number;
  dueDate: Date;
  currency: string;
  status: GoalStatus;
}
