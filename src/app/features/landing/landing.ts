import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { CreditCardHeartPic } from './ui/credit-card-heart-pic';
import { DescriptionSection } from './ui/description-section/description-section';
import { FilledBlock } from './ui/filled-block';
import { GradientBlock } from './ui/gradient-block';
import { GradientButton } from './ui/gradient-button/gradient-button';
import { LogoPic } from './ui/logo-pic';
import { SectionBudgetPic } from './ui/section-budget-pic';
import { SectionSavingsPic } from './ui/section-savings-pic';
import { SectionSpendingPic } from './ui/section-spending-pic';
import { WhiteButton } from './ui/white-button/white-button';

@Component({
  imports: [
    LogoPic,
    SectionBudgetPic,
    SectionSpendingPic,
    SectionSavingsPic,
    DescriptionSection,
    GradientBlock,
    CreditCardHeartPic,
    FilledBlock,
    GradientButton,
    WhiteButton,
  ],
  templateUrl: './landing.html',
  host: {
    class:
      'flex flex-col items-center gap-10 my-8 mx-2 sm:max-w-210 md:mx-auto',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Landing {
  private readonly router = inject(Router);

  protected readonly headerText =
    'An easy way to manage your budget, track your spending, and grow your savings — without stress or complicated spreadsheets.';

  protected readonly sectionsData = {
    budget: {
      title: 'Plan with Confidence',
      bullets: [
        'Set spending limits',
        'Organize money by categories',
        'See your progress in real time',
      ],
    },
    spending: {
      title: 'Understand Your Spending',
      bullets: [
        'Quick transaction tracking',
        'Clear monthly overview',
        'Smart insights',
      ],
    },
    savings: {
      title: 'Grow Your Savings',
      bullets: [
        'Create savings goals',
        'Track your progress',
        'Stay motivated',
      ],
    },
  };

  protected gotoLogin() {
    this.router.navigate(['/login']);
  }
}
