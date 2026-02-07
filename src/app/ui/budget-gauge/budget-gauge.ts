import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

@Component({
  selector: 'app-budget-gauge',
  template: `
    <svg class="gauge" viewBox="0 0 180 100" role="img" aria-hidden="true">
      <path
        class="arc arc--bg"
        [attr.d]="arcPath"
        [attr.stroke-dasharray]="arcLength"
        stroke-dashoffset="0"
      ></path>
      <path
        class="arc arc--fg"
        [attr.d]="arcPath"
        [attr.stroke-dasharray]="arcLength"
        [attr.stroke-dashoffset]="dashOffset()"
        [style.opacity]="progress() > 0 ? 1 : 0"
      ></path>
    </svg>
  `,
  styles: `
    :host {
      display: block;
    }

    .gauge {
      display: block;
      width: 100%;
      height: auto;
      overflow: visible;
    }

    .arc {
      fill: none;
      stroke-linecap: round;
      stroke-width: 14;
      transition: stroke-dashoffset 300ms ease;
    }

    .arc--bg {
      stroke: light-dark(var(--p-primary-100), var(--p-surface-800));
    }

    .arc--fg {
      stroke: light-dark(var(--p-primary-500), var(--p-primary-700));
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetGauge {
  readonly totalAmount = input(0);
  readonly spentAmount = input(0);

  private readonly radius = 80;
  protected readonly arcLength = Math.PI * this.radius;
  protected readonly arcPath = `M 10 90 A ${this.radius} ${this.radius} 0 0 1 170 90`;

  protected readonly progress = computed(() => {
    const total = this.totalAmount();
    const spent = this.spentAmount();

    if (total <= 0) {
      return 0;
    }

    const ratio = spent / total;

    if (ratio <= 0) {
      return 0;
    }

    if (ratio >= 1) {
      return 1;
    }

    return ratio;
  });

  protected readonly dashOffset = computed(
    () => this.arcLength * (1 - this.progress()),
  );
}
