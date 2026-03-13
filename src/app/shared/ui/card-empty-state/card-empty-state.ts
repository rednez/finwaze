import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-card-empty-state',
  imports: [ButtonModule],
  template: `
    <div class="flex flex-col items-center gap-4 max-w-xs text-center">
      <div
        class="flex items-center justify-center w-11 h-11 rounded-full bg-primary-100 dark:bg-surface-700"
      >
        <span
          class="material-symbols-rounded text-xl text-primary-500 dark:text-primary-400"
          >info</span
        >
      </div>
      <div class="flex flex-col gap-1">
        <span
          class="text-sm font-semibold text-primary-600 dark:text-primary-300"
          >{{ title() }}</span
        >
        <span
          class="text-xs text-surface-500 dark:text-surface-400 leading-relaxed"
          >{{ actionText() }}</span
        >
      </div>
      <p-button
        [label]="actionBtnLabel()"
        variant="outlined"
        size="small"
        rounded
        (onClick)="actionBtnClicked.emit()"
      />
    </div>
  `,
  host: {
    class:
      'block mt-5 bg-primary-50/70 dark:bg-surface-800 rounded-2xl py-6 px-8 w-fit mx-auto',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardEmptyState {
  readonly title = input<string>();
  readonly actionText = input<string>();
  readonly actionBtnLabel = input<string>();
  readonly actionBtnClicked = output<void>();
}
