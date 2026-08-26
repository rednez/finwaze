import { Component, input } from '@angular/core';
import { GuideSection } from '../../models';

/** Renders the article body. The host is the flex container, so the page
 *  keeps control of spacing via its own classes. */
@Component({
  selector: 'app-guide-article-sections',
  template: `
    @for (section of sections(); track $index) {
      <section>
        <h2 class="text-xl font-semibold mb-2">{{ section.heading }}</h2>
        <p class="text-slate-600 dark:text-zinc-300 leading-relaxed">
          {{ section.body }}
        </p>
      </section>
    }
  `,
})
export class GuideArticleSections {
  readonly sections = input.required<readonly GuideSection[]>();
}
