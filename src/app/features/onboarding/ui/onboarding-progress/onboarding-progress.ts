import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';

@Component({
  selector: 'app-onboarding-progress',
  templateUrl: './onboarding-progress.html',
  imports: [TranslatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OnboardingProgress {
  readonly activeIndex = input.required<number>();
  readonly total = input.required<number>();

  protected activeStep = computed(() => this.activeIndex() + 1);
  protected steps = computed(() => Array.from({ length: this.total() }));
}
