import { computed, inject, Service } from '@angular/core';
import { TRANSLATIONS } from '@core/i18n';
import { LocalizationService } from '@core/services/localization.service';
import { GUIDE_TOPICS } from '../guide-topics';
import {
  GuideArticleContent,
  GuideTopicLink,
  GuideTopicSummary,
} from '../models';

/** Joins the static topic configs with the localized guide copy, so the
 *  pages never touch `TRANSLATIONS` themselves. */
@Service()
export class GuideContent {
  private readonly lang = inject(LocalizationService).currentLang;
  private readonly guide = computed(() => TRANSLATIONS[this.lang()].guide);

  readonly hub = computed(() => this.guide().hub);
  readonly readCta = computed(() => this.guide().readCta);
  readonly tipsLabel = computed(() => this.guide().tipsLabel);
  readonly backToGuide = computed(() => this.guide().backToGuide);

  /** Hub cards, in `GUIDE_TOPICS` order. */
  readonly topicCards = computed<GuideTopicSummary[]>(() =>
    GUIDE_TOPICS.map((config) => ({
      ...config,
      ...this.guide().topics[config.key].card,
    })),
  );

  /** Article content for `key`, or `null` when the key is unknown. */
  article(key: string): GuideArticleContent | null {
    const index = GUIDE_TOPICS.findIndex((topic) => topic.key === key);
    if (index === -1) {
      return null;
    }

    const config = GUIDE_TOPICS[index];
    const { eyebrow, title, lead, sections, tips } =
      this.guide().topics[config.key];

    return {
      config,
      eyebrow,
      title,
      lead,
      sections,
      tips,
      prev: this.link(index - 1),
      next: this.link(index + 1),
    };
  }

  private link(index: number): GuideTopicLink | null {
    const config = GUIDE_TOPICS[index];
    if (!config) {
      return null;
    }
    return {
      key: config.key,
      title: this.guide().topics[config.key].card.title,
    };
  }
}
