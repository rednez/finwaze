import { ChangeDetectionStrategy, Component, output } from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';

@Component({
  selector: 'app-passkey-button',
  imports: [TranslatePipe],
  template: `
    <button
      class="relative w-full flex items-center justify-center
      gap-4 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-zinc-200
      py-4 px-6 rounded-2xl transition-all duration-300 hover:shadow-xl
      hover:shadow-violet-500/10 dark:hover:shadow-none border border-slate-200 dark:border-transparent
      active:scale-[0.98] hover:cursor-pointer font-medium"
      (click)="clickLogin.emit()"
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
        <path d="M2 18v3c0 .6.4 1 1 1h4v-3h3v-3h2l1.4-1.4a6.5 6.5 0 1 0-4-4Z" />
        <circle cx="16.5" cy="7.5" r=".5" fill="currentColor" />
      </svg>
      <span class="text-base/5 font-medium text-start">
        {{ 'login.signInWithPasskey' | translate }}
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
export class PasskeyButton {
  readonly clickLogin = output();
}
