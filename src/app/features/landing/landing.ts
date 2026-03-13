import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { LogoPic } from '@shared/ui/logo-pic';
import { DescriptionSection } from './ui/description-section/description-section';
import { GradientBlock } from './ui/gradient-block';
import { GradientButton } from './ui/gradient-button/gradient-button';
import { HowItWorksStep } from './ui/how-it-works-step';
import { SectionBudgetPic } from './ui/section-budget-pic';
import { SectionSavingsPic } from './ui/section-savings-pic';
import { SectionSpendingPic } from './ui/section-spending-pic';
import { TestimonialCard } from './ui/testimonial-card';
import { WhiteButton } from './ui/white-button/white-button';

@Component({
  imports: [
    LogoPic,
    SectionBudgetPic,
    SectionSpendingPic,
    SectionSavingsPic,
    DescriptionSection,
    GradientBlock,
    GradientButton,
    WhiteButton,
    HowItWorksStep,
    TestimonialCard,
  ],
  templateUrl: './landing.html',
  host: {
    class:
      'flex flex-col items-center gap-16 my-14 mx-4 lg:max-w-210 lg:mx-auto',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Landing {
  private readonly router = inject(Router);

  protected readonly heroBadges = [
    'Free to start',
    '2-minute setup',
    'No spreadsheets',
  ];

  protected readonly stats = [
    { value: '3 min', label: 'Average setup time' },
    { value: '100%', label: 'Free to get started' },
    { value: '24/7', label: 'Access from any device' },
  ];

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

  protected readonly howItWorksSteps = [
    {
      step: 1,
      title: 'Create your free account',
      description:
        'Sign up in seconds. No credit card required — just your email and a password.',
    },
    {
      step: 2,
      title: 'Set up your finances',
      description:
        'Add your accounts, set a monthly budget, and define your savings goals.',
    },
    {
      step: 3,
      title: 'Watch your progress',
      description:
        'Track every transaction and see your savings grow — day by day, month by month.',
    },
  ];

  protected readonly testimonials = [
    {
      quote:
        'I used to dread looking at my bank account. Now I check Finwaze every morning — it honestly changed how I feel about money.',
      author: 'Sarah M.',
      role: 'Stay-at-home parent',
    },
    {
      quote:
        'As a freelancer my income varies a lot. Finwaze helps me stay on top of everything and actually save for the slow months.',
      author: 'James L.',
      role: 'Freelance designer',
    },
    {
      quote:
        'The budgeting feature is incredibly simple. I set it up in 5 minutes and by the end of the month I had saved more than I expected.',
      author: 'Priya K.',
      role: 'Young professional',
    },
  ];

  protected gotoLogin() {
    this.router.navigate(['/login']);
  }
}
