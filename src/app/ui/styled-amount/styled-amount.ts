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
    class: 'text-2xl font-medium',
  },
})
export class StyledAmount {
  readonly currency = input.required<string>();
  readonly amount = input.required<number>();

  wholeNumber = computed(() => Math.floor(this.amount()));
  fraction = computed(() => '.' + ((this.amount() % 1) * 100).toFixed(0).padStart(2, '0'));
}
