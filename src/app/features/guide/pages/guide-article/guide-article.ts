import { Component, computed, effect, inject, input } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { GuideContent } from '../../services';
import {
  GuideArticleImage,
  GuideArticleNav,
  GuideArticleSections,
  GuideTips,
} from '../../ui';

@Component({
  imports: [
    RouterLink,
    GuideArticleImage,
    GuideArticleNav,
    GuideArticleSections,
    GuideTips,
  ],
  templateUrl: './guide-article.html',
})
export class GuideArticle {
  /** Bound from the `:topic` route param via component input binding. */
  readonly topic = input<string>('');

  private readonly router = inject(Router);
  private readonly content = inject(GuideContent);

  protected readonly article = computed(() =>
    this.content.article(this.topic()),
  );
  protected readonly tipsLabel = this.content.tipsLabel;
  protected readonly backToGuide = this.content.backToGuide;

  constructor() {
    effect(() => {
      if (!this.article()) {
        this.router.navigate(['/guide']);
      }
    });
  }
}
