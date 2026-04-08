import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { SkeletonModule } from 'primeng/skeleton';
import { GoalsListStore } from '../../stores';
import { TotalGoalItem } from '../total-goal-item/total-goal-item';

@Component({
  selector: 'app-total-goals-card',
  imports: [
    FormsModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    TotalGoalItem,
    SkeletonModule,
  ],
  template: `
    <app-card class="sm:w-89">
      <app-card-header class="flex justify-between">
        <app-card-header-title>Total Goals</app-card-header-title>
      </app-card-header>

      @if (store.isLoading()) {
        <p-skeleton class="mt-6 mb-8 h-9 w-16 rounded-lg" />
        <div class="flex gap-2 flex-wrap">
          @for (i of [1, 2, 3, 4]; track i) {
            <p-skeleton class="h-14 rounded-full grow min-w-39" />
          }
        </div>
      } @else {
        <div>
          <div class="text-3xl font-semibold mt-6 mb-8">
            {{ store.totalCount() }}
          </div>

          <div class="flex gap-2 flex-wrap">
            <app-total-goal-item
              status="notStarted"
              [count]="store.notStartedCount()"
            />
            <app-total-goal-item
              status="inProgress"
              [count]="store.inProgressCount()"
            />
            <app-total-goal-item
              status="cancelled"
              [count]="store.cancelledCount()"
            />
            <app-total-goal-item status="done" [count]="store.doneCount()" />
          </div>
        </div>
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TotalGoalsCard {
  protected readonly store = inject(GoalsListStore);
}
