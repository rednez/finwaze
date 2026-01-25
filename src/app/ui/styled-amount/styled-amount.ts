import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-styled-amount',
  imports: [DecimalPipe],
  template: `
    <span>{{ currency() }}</span>
    <span>{{ wholeNumber() | number: '1.0-0' }}</span>
    <span class="text-gray-300 dark:text-gray-500">{{ fraction() }}</span>
  `,
  host: {
    class: 'font-semibold',
    '[class.text-xl]': "size() === 'sm'",
    '[class.text-2xl]': "size() === 'md'",
    '[class.text-3xl]': "size() === 'lg'",
  },
})
export class StyledAmount {
  readonly currency = input.required<string>();
  readonly amount = input.required<number>();
  readonly size = input<'sm' | 'md' | 'lg'>('md');

  wholeNumber = computed(() => Math.floor(this.amount()));
  fraction = computed(
    () => '.' + ((this.amount() % 1) * 100).toFixed(0).padStart(2, '0'),
  );
}
