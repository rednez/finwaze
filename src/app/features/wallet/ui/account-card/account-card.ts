import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-account-card',
  imports: [CommonModule],
  template: `
    @if (isLoading()) {
      <div class="w-full flex flex-col justify-between animate-pulse">
        <div class="w-40 h-8 bg-white/30 rounded-xl"></div>
        <div class="w-full h-5 bg-white/30 rounded-xl"></div>
        <div class="w-20 h-5 bg-white/30 rounded-xl self-end"></div>
      </div>
    } @else {
      <div class="flex flex-col gap-5">
        <div class="text-2xl font-semibold">
          {{ balance() | currency: currency() }}
        </div>
        <div
          class="font-light whitespace-nowrap overflow-hidden text-ellipsis max-w-64 sm:whitespace-normal sm:max-w-full"
        >
          {{ name() }}
        </div>
      </div>
      <div class="self-end font-semibold">{{ currency() }}</div>
    }
  `,
  styles: `
    @reference "tailwindcss";

    :host {
      @apply w-full sm:w-74 h-33 sm:h-40 gap-2 p-7 rounded-3xl text-white/92 
        shadow-md shadow-purple-500/30 dark:shadow-purple-700/30 hover:shadow-lg 
        transition-shadow ease-in hover:cursor-pointer;
      display: flex;
      justify-content: space-between;
      flex-shrink: 0;
      background-image: linear-gradient(
        to right top,
        #4726de,
        #6f28e2,
        #8e2ce6,
        #a932e9,
        #c239ec
      );
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AccountCard {
  readonly balance = input(0);
  readonly currency = input<string>();
  readonly name = input<string>();
  readonly isLoading = input(false);
}
