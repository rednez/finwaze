import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { Goal } from '@models/goal';
import { GoalCard } from './ui/goal-card/goal-card';
import { TotalGoalsCard } from './ui/total-goals-card/total-goals-card';

@Component({
  selector: 'app-goals',
  imports: [GoalCard, TotalGoalsCard],
  template: `
    <div class="flex gap-4 flex-wrap">
      @for (goal of goals(); track goal.id) {
        <app-goal-card [goal]="goal" class="grow sm:max-w-80" />
      }
    </div>

    <app-total-goals-card />
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Goals {
  readonly goals = signal<Goal[]>([
    {
      id: 1,
      name: 'Buy a new laptop',
      targetAmount: 1500,
      savingAmount: 300,
      dueDate: new Date('2027-12-30'),
      currency: 'USD',
      status: 'inProgress',
    },
    {
      id: 2,
      name: `iPhone 19 Pro Pro Mega Max`,
      targetAmount: 21500,
      savingAmount: 0,
      dueDate: new Date('2026-07-30'),
      currency: 'CZK',
      status: 'notStarted',
    },
    {
      id: 3,
      name: `Dima's summer camp`,
      targetAmount: 7500,
      savingAmount: 2500,
      dueDate: new Date('2026-06-15'),
      currency: 'CZK',
      status: 'done',
    },
    {
      id: 4,
      name: `Audi R6`,
      targetAmount: 18000,
      savingAmount: 18000,
      dueDate: new Date('2024-06-15'),
      currency: 'USD',
      status: 'cancelled',
    },
  ]);
}
