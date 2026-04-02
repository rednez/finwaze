import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { SkeletonModule } from 'primeng/skeleton';
import { GoalsListStore } from './stores/goals-list-store';
import { GoalCard } from './ui/goal-card/goal-card';
import { GoalsFilters } from './ui/goals-filters/goals-filters';
import { SavingsOverviewWidget } from './ui/savings-overview-widget/savings-overview-widget';
import { TotalGoalsCard } from './ui/total-goals-card/total-goals-card';

@Component({
  selector: 'app-goals',
  imports: [
    GoalCard,
    TotalGoalsCard,
    SavingsOverviewWidget,
    GoalsFilters,
    ButtonModule,
    SkeletonModule,
  ],
  template: `
    <div class="flex justify-between gap-4">
      <app-goals-filters />

      <p-button
        icon="pi pi-plus"
        label="Add new goal"
        [rounded]="true"
        size="large"
        class="shrink-0"
        [dt]="{ root: { lg: { fontSize: '14px' } } }"
      />
    </div>

    <div class="flex gap-4 flex-wrap">
      @if (goalsListStore.isLoading()) {
        @for (i of [1, 2, 3]; track i) {
          <p-skeleton class="grow sm:max-w-80 rounded-3xl h-56" />
        }
      } @else if (goalsListStore.goals().length === 0) {
        <div class="text-muted-color py-8 text-center w-full">No goals found</div>
      } @else {
        @for (goal of goalsListStore.goals(); track goal.id) {
          <app-goal-card [goal]="goal" class="grow sm:max-w-80" />
        }
      }
    </div>

    <div class="flex gap-4 flex-wrap">
      <app-total-goals-card />

      <app-savings-overview-widget class="grow lg:flex-1 min-w-0" />
    </div>
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Goals {
  protected readonly goalsListStore = inject(GoalsListStore);
}
