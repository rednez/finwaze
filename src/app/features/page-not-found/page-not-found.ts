import { Component } from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';

@Component({
  imports: [TranslatePipe],
  template: `
    <div
      class="font-mono bg-primary-100 dark:bg-surface-800 py-10 px-14 rounded-4xl text-center"
    >
      <h1 class="text-8xl">404</h1>
      <p class="text-xl text-muted-color-emphasis uppercase">
        {{ 'misc.pageNotFound.notFound' | translate }}
      </p>
    </div>
  `,
  styles: `
    @reference "tailwindcss";
    :host {
      @apply flex flex-col items-center justify-center h-[calc(100vh-90px)];
    }
  `,
})
export class PageNotFound {}
