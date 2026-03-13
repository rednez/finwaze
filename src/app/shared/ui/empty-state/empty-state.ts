import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-empty-state',
  imports: [ButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div
      class="flex flex-col items-center justify-center py-16 px-8 text-center"
    >
      <!-- Illustration area -->
      <div class="relative mb-8">
        <!-- Outer glow ring -->
        <div
          class="absolute inset-0 rounded-full bg-linear-to-br from-violet-200/60 to-purple-200/40 dark:from-violet-500/20 dark:to-purple-500/15 blur-xl scale-125"
        ></div>
        <!-- Icon container -->
        <div
          class="relative flex items-center justify-center w-24 h-24 rounded-3xl bg-linear-to-br from-violet-100 to-purple-100 dark:from-violet-900/40 dark:to-purple-900/35 shadow-lg shadow-violet-200/50 dark:shadow-violet-900/40 border border-violet-100 dark:border-violet-800/40"
        >
          @if (icon()) {
            <span class="material-symbols-rounded text-violet-500 text-4xl">{{
              icon()
            }}</span>
          } @else {
            <svg
              class="w-12 h-12 text-violet-400"
              viewBox="0 0 48 48"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              aria-hidden="true"
            >
              <rect
                x="6"
                y="10"
                width="36"
                height="28"
                rx="4"
                stroke="currentColor"
                stroke-width="2.5"
                fill="none"
              />
              <path
                d="M6 18h36"
                stroke="currentColor"
                stroke-width="2.5"
                stroke-linecap="round"
              />
              <path
                d="M16 26h8M16 32h5"
                stroke="currentColor"
                stroke-width="2.5"
                stroke-linecap="round"
              />
              <circle
                cx="36"
                cy="30"
                r="6"
                fill="white"
                stroke="currentColor"
                stroke-width="2"
              />
              <path
                d="M36 28v2.5l1.5 1.5"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
              />
            </svg>
          }

          <!-- Decorative dots -->
          <span
            class="absolute -top-1.5 -right-1.5 w-3 h-3 rounded-full bg-violet-400 opacity-80"
          ></span>
          <span
            class="absolute -bottom-1 -left-1.5 w-2 h-2 rounded-full bg-purple-300 opacity-70"
          ></span>
        </div>
      </div>

      <div class="max-w-xs">
        <h3
          class="text-lg font-semibold text-surface-800 dark:text-surface-100 mb-2 tracking-tight"
        >
          {{ title() }}
        </h3>

        <p
          class="text-sm text-surface-500 dark:text-surface-400 leading-relaxed mb-6"
        >
          {{ description() }}
        </p>

        <p-button
          icon="pi pi-plus"
          [label]="buttonText()"
          [rounded]="true"
          size="large"
          class="shrink-0"
          [dt]="{ root: { lg: { fontSize: '14px' } } }"
          (onClick)="actionClicked.emit()"
        />
      </div>

      <div
        class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 rounded-full bg-violet-50/60 dark:bg-violet-950/10 -z-10 pointer-events-none"
      ></div>
    </div>
  `,
  host: {
    class: 'relative block overflow-hidden',
  },
})
export class EmptyState {
  readonly title = input.required<string>();
  readonly description = input.required<string>();
  readonly buttonText = input.required<string>();
  readonly icon = input<string>();

  readonly actionClicked = output<void>();
}
