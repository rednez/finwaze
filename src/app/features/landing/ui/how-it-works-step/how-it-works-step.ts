import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-how-it-works-step',
  imports: [],
  template: `
    <div class="step-badge">{{ step() }}</div>
    <h3
      class="font-bold text-base tracking-tight text-gray-800 dark:text-gray-100 mb-2"
    >
      {{ title() }}
    </h3>
    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">
      {{ description() }}
    </p>
  `,
  host: {
    class: 'flex flex-col flex-1',
  },
  styles: `
    :host {
      padding: 28px;
      border-radius: 20px;
      background: light-dark(#fafafa, var(--p-surface-800));
      border: 1px solid light-dark(#efeff5, rgba(255, 255, 255, 0.05));
      box-shadow: 0 2px 16px
        light-dark(rgba(94, 35, 233, 0.05), rgba(0, 0, 0, 0.16));
      position: relative;
      overflow: hidden;
    }

    :host::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: linear-gradient(90deg, #5e23e9, #ca27f3);
      opacity: 0.5;
    }

    .step-badge {
      width: 40px;
      height: 40px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: 700;
      font-size: 1rem;
      margin-bottom: 1.5rem;
      flex-shrink: 0;
      background: linear-gradient(135deg, #5e23e9, #ca27f3);
      box-shadow: 0 4px 12px rgba(94, 35, 233, 0.3);
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HowItWorksStep {
  readonly step = input(1);
  readonly title = input('');
  readonly description = input('');
}
