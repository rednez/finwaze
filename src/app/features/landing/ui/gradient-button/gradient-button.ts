import { ChangeDetectionStrategy, Component, output } from '@angular/core';

@Component({
  selector: 'app-gradient-button',
  imports: [],
  template: ` <button (click)="getStarted.emit()">Get Started</button> `,
  styles: `
    :host {
      display: block;
    }

    button {
      border-radius: 50px;
      background: linear-gradient(90deg, #5e23e9 0%, #ca27f3 100%);
      padding: 15px 52px;
      color: #fff;
      font-weight: 600;
      font-size: 0.9375rem;
      letter-spacing: 0.01em;
      box-shadow: 0 6px 24px rgba(94, 35, 233, 0.38);
      transition:
        transform 0.2s ease,
        box-shadow 0.2s ease,
        opacity 0.2s ease;

      &:hover {
        cursor: pointer;
        transform: translateY(-2px);
        box-shadow: 0 10px 32px rgba(94, 35, 233, 0.48);
        opacity: 0.95;
      }

      &:active {
        transform: translateY(0);
        box-shadow: 0 4px 16px rgba(94, 35, 233, 0.3);
      }
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GradientButton {
  readonly getStarted = output();
}
