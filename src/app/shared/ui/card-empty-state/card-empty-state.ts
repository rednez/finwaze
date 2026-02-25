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
    <div class="max-w-70 text-center text-primary-500 dark:text-primary-400">
      <div class="flex gap-2 justify-center">
        <div class="material-symbols-rounded">info</div>
        <div class="font-medium">{{ title() }}</div>
      </div>

      <div class="mt-4">
        <div class="text-sm">
          {{ actionText() }}
        </div>
        <div class="mt-3">
          <p-button
            [label]="actionBtnLabel()"
            variant="outlined"
            size="small"
            rounded
            (onClick)="actionBtnClicked.emit()"
          />
        </div>
      </div>
    </div>
  `,
  host: {
    class:
      'block mt-5 bg-primary-50 dark:bg-surface-800 rounded-3xl py-4 px-6 w-fit mx-auto',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardEmptyState {
  readonly title = input<string>();
  readonly actionText = input<string>();
  readonly actionBtnLabel = input<string>();
  readonly actionBtnClicked = output<void>();
}
