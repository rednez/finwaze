export type GuideTopicKey =
  | 'dashboard'
  | 'transactions'
  | 'categories'
  | 'wallet'
  | 'budget'
  | 'goals'
  | 'analytics';

/** Intrinsic size of a topic screenshot, required by `NgOptimizedImage`.
 *  Update it whenever the Cloudinary asset is replaced. */
export interface GuideTopicImage {
  width: number;
  height: number;
}

/** Presentation config for a topic. All copy lives in the translations. */
export interface GuideTopicConfig {
  key: GuideTopicKey;
  image: GuideTopicImage;
  icon: string;
  /** Static Tailwind classes (kept literal so they survive purging). */
  iconClass: string;
  accentClass: string;
}

/** A topic config joined with its localized card copy — one hub card. */
export interface GuideTopicSummary extends GuideTopicConfig {
  title: string;
  summary: string;
}

/** Minimal topic reference used by the prev/next article navigation. */
export interface GuideTopicLink {
  key: GuideTopicKey;
  title: string;
}

export interface GuideSection {
  heading: string;
  body: string;
}

/** Everything a single article page renders. */
export interface GuideArticleContent {
  config: GuideTopicConfig;
  eyebrow: string;
  title: string;
  lead: string;
  sections: readonly GuideSection[];
  tips: readonly string[];
  prev: GuideTopicLink | null;
  next: GuideTopicLink | null;
}
