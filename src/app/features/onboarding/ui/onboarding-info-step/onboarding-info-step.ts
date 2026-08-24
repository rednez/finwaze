import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ButtonModule } from 'primeng/button';
import { NgOptimizedImage } from '@angular/common';
import { OnboardingInfoStep as OnboardingInfoStepModel } from '../../models/onboarding-step';
import { ThemeService } from '@core/services/theme.service';

@Component({
  selector: 'app-onboarding-info-step',
  imports: [ButtonModule, TranslatePipe, NgOptimizedImage],
  templateUrl: './onboarding-info-step.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OnboardingInfoStep {
  readonly step = input.required<OnboardingInfoStepModel>();
  /** Whether to offer a "Back" action (hidden on the first page). */
  readonly showBack = input.required<boolean>();
  /** Label for the primary button ("Next" or "Let's get started"). */
  readonly nextLabel = input.required<string>();

  readonly back = output<void>();
  readonly next = output<void>();
  readonly skip = output<void>();

  private readonly isDark = inject(ThemeService).isDark;

  protected readonly imageName = computed(
    () =>
      'finwaze/onboarding/' +
      this.step().image.name +
      `-${this.isDark() ? 'dark' : 'light'}`,
  );
}
