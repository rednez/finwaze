import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { ProgressBar } from '@shared/ui/progress-bar';
import { RecentSavingsGoal } from '../../models';

@Component({
  selector: 'app-saving-goals-widget',
  imports: [CommonModule, Card, ProgressBar, CardHeader, CardHeaderTitle],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>Savings goals</app-card-header-title>
      </app-card-header>

      <div class="flex flex-col gap-4">
        @for (goal of formattedGoals(); track goal.id) {
          <div>
            <div class="flex justify-between gap-1 text-sm mb-1">
              <div class="font-medium max-w-50 truncate">{{ goal.name }}</div>
              <div class="text-primary-500">
                {{ goal.targetAmount | currency: goal.currency }}
              </div>
            </div>

            <app-progress-bar [value]="goal.savedAmountPercent" />
          </div>
        }
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SavingGoalsWidget {
  readonly goals = input<RecentSavingsGoal[]>([]);

  readonly formattedGoals = computed(() =>
    this.goals().map((i) => ({
      ...i,
      savedAmountPercent: Math.floor((i.currentAmount / i.targetAmount) * 100),
    })),
  );
}
