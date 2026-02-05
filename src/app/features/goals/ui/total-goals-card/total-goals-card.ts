import { ChangeDetectionStrategy, Component } from '@angular/core';
import { Card } from '@ui/card';
import { CardHeader } from '@ui/card-header/card-header';
import { CardHeaderTitle } from '@ui/card-header-title/card-header-title';
import { TotalGoalItem } from '../total-goal-item/total-goal-item';

@Component({
  selector: 'app-total-goals-card',
  imports: [Card, CardHeader, CardHeaderTitle, TotalGoalItem],
  template: `
    <app-card class="sm:w-89">
      <app-card-header>
        <app-card-header-title>Total Goals</app-card-header-title>
      </app-card-header>

      <div class="text-3xl font-semibold mb-4">25</div>

      <div class="flex gap-2 flex-wrap">
        <app-total-goal-item status="notStarted" [count]="2" />
        <app-total-goal-item status="inProgress" [count]="1" />
        <app-total-goal-item status="cancelled" [count]="3" />
        <app-total-goal-item status="done" [count]="1" />
      </div>
    </app-card>
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TotalGoalsCard {}
