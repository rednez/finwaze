/** A single informational tour page, paired with its illustration. */
export interface OnboardingInfoStep {
  eyebrow: string;
  title: string;
  description: string;
  bullets: string[];
  image: { name: string; width: number; height: number };
}

/** Copy for the final, critical account-creation page. */
export interface OnboardingAccountStep {
  eyebrow: string;
  title: string;
  description: string;
  createBtn: string;
  creationFailed: string;
  guideHint: string;
}

/** Payload emitted when the user submits the account-creation form. */
export interface OnboardingAccountSubmit {
  accountName: string;
  currencyId: number;
}
