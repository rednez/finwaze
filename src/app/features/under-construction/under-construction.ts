import { ChangeDetectionStrategy, Component } from '@angular/core';
import { LogoPic } from '@shared/ui/logo-pic';

@Component({
  template: `
    <header class="flex items-center justify-between w-full px-4 lg:px-0">
      <app-logo-pic />
    </header>

    <section class="w-full text-center relative pt-4 pb-2 mt-16">
      <div
        class="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-56 bg-linear-to-b from-violet-200/70 dark:from-violet-800/20 to-transparent blur-3xl -z-10 rounded-full"
        aria-hidden="true"
      ></div>

      <p
        class="inline-flex items-center justify-center rounded-full border border-violet-200 bg-white/80 px-4 py-1 text-sm font-semibold tracking-wide text-violet-700 shadow-sm backdrop-blur dark:border-violet-500/30 dark:bg-gray-900/70 dark:text-violet-200"
      >
        Coming soon
      </p>

      <h1
        class="text-4xl sm:text-5xl font-extrabold tracking-tight text-gray-900 dark:text-gray-50 leading-[1.1] mt-6 mb-6"
      >
        Finwaze is in active<br class="hidden sm:block" />
        development
      </h1>

      <p
        class="text-base sm:text-lg text-muted-color-emphasis leading-relaxed max-w-xl mx-auto mb-4"
      >
        Finwaze is being built to make personal finance tracking simpler,
        clearer, and faster.
      </p>

      <p
        class="text-sm sm:text-base text-muted-color leading-relaxed max-w-lg mx-auto"
      >
        The web app is not available yet, but the public launch is coming soon.
        Check back shortly.
      </p>
    </section>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex flex-col items-center mt-8 mx-4 lg:max-w-210 lg:mx-auto',
  },
  imports: [LogoPic],
})
export class UnderConstruction {}
