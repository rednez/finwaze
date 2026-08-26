import { Component, input } from '@angular/core';

@Component({
  selector: 'app-guide-quick-start',
  template: `
    <section
      class="rounded-3xl border border-violet-200/60 dark:border-violet-500/20 bg-violet-500/5 p-6 sm:p-8"
    >
      <h2 class="text-lg font-semibold mb-5">{{ title() }}</h2>
      <ol class="flex flex-col gap-4">
        @for (step of steps(); track $index) {
          <li class="flex items-start gap-4">
            <span
              class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full bg-violet-500 text-sm font-semibold text-white"
            >
              {{ $index + 1 }}
            </span>
            <span
              class="pt-0.5 text-slate-600 dark:text-zinc-300 leading-relaxed"
            >
              {{ step }}
            </span>
          </li>
        }
      </ol>
    </section>
  `,
})
export class GuideQuickStart {
  readonly title = input.required<string>();
  readonly steps = input.required<readonly string[]>();
}
