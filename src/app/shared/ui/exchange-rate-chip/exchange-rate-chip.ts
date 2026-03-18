import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-exchange-rate-chip',
  imports: [CommonModule],
  template: `
    @if (exchangeRate()) {
      <div
        class="text-xs font-medium px-2 py-1 bg-gray-100 dark:bg-gray-800 rounded-lg"
      >
        {{ exchangeRate() | number: '1.1-4' }}
      </div>
    }
  `,
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply flex gap-1;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExchangeRateChip {
  readonly exchangeRate = input<number | null>();
}
