import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  output,
} from '@angular/core';
import { SavingsGoal } from '@core/models/savings-goal';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { Card } from '@shared/ui/card';
import { CardEmptyState } from '@shared/ui/card-empty-state';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { ProgressBar } from '@shared/ui/progress-bar';

@Component({
  selector: 'app-saving-goals-widget',
  imports: [
    CommonModule,
    Card,
    ProgressBar,
    CardHeader,
    CardHeaderTitle,
    CardEmptyState,
    TranslatePipe,
  ],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>{{
          'dashboard.savingGoalsWidget.title' | translate
        }}</app-card-header-title>
      </app-card-header>

      @if (goals().length > 0) {
        <div class="flex flex-col gap-4">
          @for (goal of formattedGoals(); track goal.id) {
            <div>
              <div class="flex justify-between gap-1 text-sm mb-1">
                <div class="font-medium max-w-50 truncate">{{ goal.name }}</div>
                <div class="text-primary-500">
                  {{ goal.targetAmount | currency: goal.currencyCode }}
                </div>
              </div>

              <app-progress-bar [value]="goal.savedAmountPercent" />
            </div>
          }
        </div>
      } @else {
        <app-card-empty-state
          [title]="'dashboard.savingGoalsWidget.noGoals' | translate"
          [actionText]="
            'dashboard.savingGoalsWidget.createGoalsText' | translate
          "
          [actionBtnLabel]="'dashboard.savingGoalsWidget.gotoGoals' | translate"
          (actionBtnClicked)="actionClicked.emit()"
        />
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SavingGoalsWidget {
  readonly goals = input<SavingsGoal[]>([]);
  readonly actionClicked = output<void>();

  readonly formattedGoals = computed(() =>
    this.goals().map((i) => ({
      ...i,
      savedAmountPercent: Math.floor(
        (i.accumulatedAmount / i.targetAmount) * 100,
      ),
    })),
  );
}
