import { CurrencyPipe, DecimalPipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  LOCALE_ID,
} from '@angular/core';

@Component({
  selector: 'app-styled-amount',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <span>{{ mainPart() }}</span
    ><span class="text-gray-300 dark:text-gray-500">{{ decimalPart() }}</span
    ><span>{{ suffixPart() }}</span>
  `,
  host: {
    class: 'font-semibold',
    '[class.text-large]': "size() === 'xs'",
    '[class.text-xl]': "size() === 'sm'",
    '[class.text-2xl]': "size() === 'md'",
    '[class.text-3xl]': "size() === 'lg'",
  },
})
export class StyledAmount {
  readonly currency = input<string>();
  readonly amount = input.required<number>();
  readonly size = input<'xs' | 'sm' | 'md' | 'lg'>('md');

  private readonly locale = inject(LOCALE_ID);
  private readonly currencyPipe = new CurrencyPipe(this.locale);
  private readonly decimalPipe = new DecimalPipe(this.locale);
  private readonly decimalSeparator =
    new Intl.NumberFormat(this.locale)
      .formatToParts(1.1)
      .find((part) => part.type === 'decimal')?.value ?? '.';

  private readonly formattedAmount = computed(
    () =>
      (this.currency()
        ? this.currencyPipe.transform(this.amount(), this.currency())
        : this.decimalPipe.transform(this.amount())) ?? '',
  );

  private readonly parsedParts = computed(() => {
    const formatted = this.formattedAmount();
    const lastSeparatorIndex = formatted.lastIndexOf(this.decimalSeparator);

    if (lastSeparatorIndex === -1) {
      return { main: formatted, decimal: '', suffix: '' };
    }

    const main = formatted.slice(0, lastSeparatorIndex);
    const afterSeparator = formatted.slice(lastSeparatorIndex);

    // Extract only the decimal separator and digits
    const decimalMatch = afterSeparator.match(
      new RegExp(`^\\${this.decimalSeparator}\\d+`),
    );
    const decimal = decimalMatch ? decimalMatch[0] : '';
    const suffix = afterSeparator.slice(decimal.length);

    return { main, decimal, suffix };
  });

  readonly mainPart = computed(() => this.parsedParts().main);
  readonly decimalPart = computed(() => this.parsedParts().decimal);
  readonly suffixPart = computed(() => this.parsedParts().suffix);
}
