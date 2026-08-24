import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { Router } from '@angular/router';
import { TRANSLATIONS } from '@core/i18n';
import { LocalizationService } from '@core/services/localization.service';
import { MessageService } from 'primeng/api';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToastModule } from 'primeng/toast';
import { OnboardingAccountSubmit } from './models/onboarding-step';
import { OnboardingService } from './onboarding.service';
import { OnboardingAccountStep } from './ui/onboarding-account-step';
import { OnboardingInfoStep } from './ui/onboarding-info-step';
import { OnboardingProgress } from './ui/onboarding-progress';

const STEP_IMAGES = [
  { name: 'welcome', width: 1866, height: 1208 },
  { name: 'transactions', width: 1866, height: 736 },
  { name: 'categories', width: 1866, height: 934 },
  { name: 'budget', width: 1866, height: 1189 },
  { name: 'goals', width: 1866, height: 1016 },
  { name: 'analytics', width: 1866, height: 1254 },
];

@Component({
  imports: [
    ProgressSpinnerModule,
    ToastModule,
    OnboardingProgress,
    OnboardingInfoStep,
    OnboardingAccountStep,
  ],
  templateUrl: './onboarding.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Onboarding {
  private readonly router = inject(Router);
  private readonly service = inject(OnboardingService);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private readonly t = (key: string) => this.localizationService.translate(key);
  private readonly lang = this.localizationService.currentLang;

  protected readonly isLoading = this.service.isLoading;
  protected readonly isCurrenciesLoading = this.service.isCurrenciesLoading;
  protected readonly currencies = this.service.currencies;

  protected readonly infoSteps = computed(() =>
    TRANSLATIONS[this.lang()].misc.onboarding.steps.map((step, index) => ({
      ...step,
      image: STEP_IMAGES[index],
    })),
  );
  protected readonly accountStep = computed(
    () => TRANSLATIONS[this.lang()].misc.onboarding.account,
  );
  /** Accessible labels for every progress dot, tour pages plus account page. */
  protected readonly stepLabels = computed(() => [
    ...this.infoSteps().map((step) => step.eyebrow),
    this.accountStep().eyebrow,
  ]);

  /** Current page index. Indices 0..infoSteps-1 are tour pages; the final
   *  index is the (critical) account-creation page. */
  protected readonly currentStep = signal(0);
  protected readonly totalSteps = computed(() => this.infoSteps().length + 1);
  protected readonly isAccountStep = computed(
    () => this.currentStep() === this.totalSteps() - 1,
  );
  protected readonly currentInfoStep = computed(
    () => this.infoSteps()[this.currentStep()] ?? null,
  );
  protected readonly progressLabel = computed(() =>
    this.t('misc.onboarding.stepCounter')
      .replace('{current}', String(this.currentStep() + 1))
      .replace('{total}', String(this.totalSteps())),
  );
  /** On the final tour page the primary button leads into account creation. */
  protected readonly nextLabel = computed(() =>
    this.currentStep() === this.infoSteps().length - 1
      ? this.t('misc.onboarding.getStarted')
      : this.t('misc.onboarding.next'),
  );

  constructor() {
    this.initialize();
  }

  protected next() {
    if (!this.isAccountStep()) {
      this.currentStep.update((step) => step + 1);
    }
  }

  protected back() {
    if (this.currentStep() > 0) {
      this.currentStep.update((step) => step - 1);
    }
  }

  /** Skip the remaining tour pages and jump straight to account creation. */
  protected skip() {
    this.currentStep.set(this.totalSteps() - 1);
  }

  protected goToStep(index: number) {
    this.currentStep.set(index);
  }

  protected async createAccount({
    accountName,
    currencyId,
  }: OnboardingAccountSubmit) {
    const { error } = await this.service.createAccount(accountName, currencyId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('misc.onboarding.account.creationFailed'),
        detail: error.message,
      });
    } else {
      this.router.navigate(['dashboard']);
    }
  }

  private async initialize() {
    const hasAccounts = await this.service.loadAccounts();
    if (hasAccounts) {
      this.router.navigate(['dashboard']);
    } else {
      this.service.loadCurrencies();
    }
  }
}
