import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-currency-code-chip',
  template: ` {{ currencyCode() }} `,
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply text-xs font-medium px-2 py-1 bg-gray-100 dark:bg-gray-800 rounded-lg;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CurrencyCodeChip {
  readonly currencyCode = input<string | null>();
}
