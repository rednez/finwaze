import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';

@Component({
  selector: 'app-goal-not-found',
  imports: [TranslatePipe],
  template: `
    <div class="flex flex-col items-center gap-4 py-12 text-center">
      <div
        class="flex items-center justify-center w-16 h-16 rounded-2xl bg-surface-100 dark:bg-surface-800"
      >
        <span class="material-symbols-rounded text-surface-400 text-3xl">
          search_off
        </span>
      </div>
      <div>
        <p class="font-semibold text-surface-800 dark:text-surface-100 mb-1">
          {{ 'goals.notFound.title' | translate }}
        </p>
        <p class="text-sm text-muted-color">
          {{ 'goals.notFound.description' | translate }}
        </p>
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalNotFound {}
