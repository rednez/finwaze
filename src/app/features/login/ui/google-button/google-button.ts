import { ChangeDetectionStrategy, Component, output } from '@angular/core';
import { GooglePic } from '../google-pic/google-pic';

@Component({
  selector: 'app-google-button',
  imports: [GooglePic],
  template: `
    <button
      class="group relative w-full flex items-center justify-center 
      gap-4 bg-white dark:bg-zinc-800 text-zinc-900 dark:text-zinc-200 font-semibold 
      py-4 px-6 rounded-2xl transition-all duration-300 hover:shadow-xl
      hover:shadow-violet-500/10 dark:hover:shadow-none border border-slate-200 dark:border-transparent 
      active:scale-[0.98] hover:cursor-pointer"
      (click)="clickLogin.emit()"
    >
      <app-google-pic />
      <span class="font-semibold">Continue with Google</span>
    </button>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoogleButton {
  readonly clickLogin = output();
}
