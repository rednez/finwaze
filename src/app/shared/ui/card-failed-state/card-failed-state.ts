import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-card-failed-state',
  imports: [ButtonModule],
  template: `
    <div
      class="w-fit  mx-auto flex items-center justify-center gap-2 bg-red-100 dark:bg-surface-800
      text-red-700 dark:text-surface-400 rounded-full py-1 pl-2 pr-4 mb-3 border border-red-200 dark:border-surface-700"
    >
      <span class="material-symbols-rounded"> error </span>
      <div class="text-sm">Failed data loading</div>
    </div>

    <p-button
      label="Try again"
      variant="outlined"
      severity="secondary"
      size="small"
    />
  `,
  styles: `
    :host {
      display: block;
      text-align: center;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardFailedState {}
