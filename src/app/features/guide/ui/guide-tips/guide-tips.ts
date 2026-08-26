import { Component, input } from '@angular/core';

@Component({
  selector: 'app-guide-tips',
  template: `
    <section
      class="rounded-3xl border border-surface-200 dark:border-surface-700 bg-surface-50 dark:bg-zinc-900/40 p-6 sm:p-8"
    >
      <h2 class="flex items-center gap-2 text-lg font-semibold mb-5">
        <i class="pi pi-star-fill text-amber-400"></i>
        {{ label() }}
      </h2>
      <ul class="flex flex-col gap-4">
        @for (tip of tips(); track $index) {
          <li class="flex items-start gap-3">
            <i class="pi pi-check-circle mt-0.5 text-emerald-500"></i>
            <span class="text-slate-600 dark:text-zinc-300 leading-relaxed">
              {{ tip }}
            </span>
          </li>
        }
      </ul>
    </section>
  `,
})
export class GuideTips {
  readonly label = input.required<string>();
  readonly tips = input.required<readonly string[]>();
}
