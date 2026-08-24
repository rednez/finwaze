import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { Currency } from '@core/models/currencies';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { NewAccountForm } from '@shared/ui/new-account-form';
import { ButtonModule } from 'primeng/button';
import {
  OnboardingAccountStep as OnboardingAccountStepModel,
  OnboardingAccountSubmit,
} from '../../models/onboarding-step';

@Component({
  selector: 'app-onboarding-account-step',
  imports: [ButtonModule, NewAccountForm, TranslatePipe],
  templateUrl: './onboarding-account-step.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OnboardingAccountStep {
  readonly step = input.required<OnboardingAccountStepModel>();
  readonly isCurrenciesLoading = input(false);
  readonly currencies = input<Currency[]>([]);

  readonly back = output<void>();
  readonly submitForm = output<OnboardingAccountSubmit>();

  protected submit(event: { accountName: string; currencyId?: number }) {
    this.submitForm.emit({
      accountName: event.accountName,
      currencyId: event.currencyId!,
    });
  }
}
