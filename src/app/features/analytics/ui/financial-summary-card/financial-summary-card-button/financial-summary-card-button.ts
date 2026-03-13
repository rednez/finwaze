import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-financial-summary-card-button',
  imports: [ButtonModule],
  template: `
    <p-button variant="text" size="small" rounded>
      <div class="flex items-center gap-2">
        <div class="bg-primary-100 dark:bg-surface-800 flex p-2 rounded-full">
          <span
            class="material-symbols-rounded dark:text-primary-500 text-[18px]!"
          >
            {{ icon() }}
          </span>
        </div>
        <span class="text-gray-800 dark:text-surface-300 font-medium">
          <span>{{ count() }}</span>
          <span class="ml-0.5">{{ label() }}</span>
        </span>
      </div>
    </p-button>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinancialSummaryCardButton {
  readonly label = input('');
  readonly count = input(0);
  readonly icon = input('');
}
