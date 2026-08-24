import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { GuideTopicSummary } from '../../models';

@Component({
  selector: 'app-guide-topic-card',
  imports: [RouterLink],
  // The link itself is the grid item — the host must not create a box.
  host: { class: 'contents' },
  template: `
    <a
      [routerLink]="['/guide', topic().key]"
      class="group flex flex-col rounded-3xl border border-surface-200 dark:border-surface-700 bg-white/60 dark:bg-zinc-900/40 p-6 transition-all hover:-translate-y-0.5 hover:shadow-lg hover:shadow-violet-500/10"
    >
      <span
        class="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl text-xl"
        [class]="topic().iconClass"
      >
        <i [class]="topic().icon"></i>
      </span>
      <h3 class="text-lg font-semibold">{{ topic().title }}</h3>
      <p
        class="mt-2 flex-1 text-sm text-slate-500 dark:text-zinc-400 leading-relaxed"
      >
        {{ topic().summary }}
      </p>
      <span
        class="mt-4 inline-flex items-center gap-1.5 text-sm font-medium"
        [class]="topic().accentClass"
      >
        {{ readCta() }}
        <i
          class="pi pi-arrow-right text-xs transition-transform group-hover:translate-x-0.5"
        ></i>
      </span>
    </a>
  `,
})
export class GuideTopicCard {
  readonly topic = input.required<GuideTopicSummary>();
  readonly readCta = input.required<string>();
}
