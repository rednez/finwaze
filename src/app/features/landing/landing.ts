import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { Router } from '@angular/router';
import { TRANSLATIONS } from '@core/i18n';
import { LocalizationService } from '@core/services/localization.service';
import { LangSwitcher } from '@shared/ui/lang-switcher';
import { LogoPic } from '@shared/ui/logo-pic';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { DescriptionSection } from './ui/description-section/description-section';
import { GradientBlock } from './ui/gradient-block';
import { GradientButton } from './ui/gradient-button/gradient-button';
import { HowItWorksStep } from './ui/how-it-works-step';
import { SectionBudgetPic } from './ui/section-budget-pic';
import { SectionSavingsPic } from './ui/section-savings-pic';
import { SectionSpendingPic } from './ui/section-spending-pic';
import { TestimonialCard } from './ui/testimonial-card';
import { WhiteButton } from './ui/white-button/white-button';
import { ThemeSwitcher } from '@shared/ui/theme-switcher';

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
    ThemeSwitcher,
    LangSwitcher,
    TranslatePipe,
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
  private readonly localizationService = inject(LocalizationService);

  private readonly lang = this.localizationService.currentLang;

  protected readonly heroBadges = computed(() => TRANSLATIONS[this.lang()].landing.heroBadges);
  protected readonly stats = computed(() => TRANSLATIONS[this.lang()].landing.stats);
  protected readonly sectionsData = computed(() => TRANSLATIONS[this.lang()].landing.sectionsData);
  protected readonly howItWorksSteps = computed(() => TRANSLATIONS[this.lang()].landing.howItWorksSteps);
  protected readonly testimonials = computed(() => TRANSLATIONS[this.lang()].landing.testimonialsList);

  protected readonly currentYear = new Date().getFullYear();

  protected gotoLogin() {
    this.router.navigate(['/login']);
  }
}
