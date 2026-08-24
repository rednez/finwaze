import { NgOptimizedImage } from '@angular/common';
import { Component, computed, inject, input } from '@angular/core';
import { ThemeService } from '@core/services/theme.service';
import { GuideTopicConfig } from '../../models';

/** Article screenshot, served from Cloudinary in the current theme.
 *  Both `finwaze/guide/<key>-light` and `-dark` must exist. */
@Component({
  selector: 'app-guide-article-image',
  imports: [NgOptimizedImage],
  template: `
    <img
      [ngSrc]="src()"
      ngSrcset="720w, 1440w, 1866w"
      sizes="(min-width: 768px) 720px, 100vw"
      [alt]="alt()"
      [width]="topic().image.width"
      [height]="topic().image.height"
      placeholder
      priority
      class="w-full rounded-3xl border border-surface-200 dark:border-surface-700 shadow-lg shadow-violet-500/10"
    />
  `,
})
export class GuideArticleImage {
  readonly topic = input.required<GuideTopicConfig>();
  readonly alt = input.required<string>();

  private readonly isDark = inject(ThemeService).isDark;

  protected readonly src = computed(
    () =>
      `finwaze/guide/${this.topic().key}-${this.isDark() ? 'dark' : 'light'}`,
  );
}
