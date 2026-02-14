import { ChangeDetectionStrategy, Component, output } from '@angular/core';

@Component({
  selector: 'app-demo-button',
  template: `
    <button
      class="group relative w-full flex items-center justify-center 
      gap-4 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-zinc-200 
      py-4 px-6 rounded-2xl transition-all duration-300 hover:shadow-xl
      hover:shadow-violet-500/10 dark:hover:shadow-none border border-slate-200 dark:border-transparent 
      active:scale-[0.98] hover:cursor-pointer font-medium"
      (click)="clickLogin.emit()"
    >
      <span>Try Demo Mode</span>
    </button>
  `,
  styles: `
    :host {
      display: block;
    }

    span {
      background: linear-gradient(90deg, #5e23e9 0%, #ca27f3 100%);
      background-clip: text;
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DemoButton {
  readonly clickLogin = output();
}
