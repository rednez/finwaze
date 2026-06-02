import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';

@Component({
  selector: 'app-email-auth-button',
  template: `
    <button
      class="relative w-full flex items-center justify-center
      gap-4 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-zinc-200
      py-4 px-6 rounded-2xl transition-all duration-300 hover:shadow-xl
      hover:shadow-violet-500/10 dark:hover:shadow-none border border-slate-200 dark:border-transparent
      active:scale-[0.98] hover:cursor-pointer font-medium"
      (click)="clickAction.emit()"
    >
      <svg
        class="w-5 h-5 text-violet-500 shrink-0"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      >
        <rect x="2" y="4" width="20" height="16" rx="2" />
        <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
      </svg>
      <span class="font-medium tracking-tight sm:tracking-normal text-nowrap">
        {{ label() }}
      </span>
    </button>
  `,
  styles: `
    :host {
      display: block;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EmailAuthButton {
  readonly label = input.required<string>();
  readonly clickAction = output();
}
