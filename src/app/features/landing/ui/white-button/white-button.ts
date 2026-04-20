import { ChangeDetectionStrategy, Component, output } from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';

@Component({
  selector: 'app-white-button',
  imports: [TranslatePipe],
  template: `
    <button (click)="getStarted.emit()">
      <span>{{ 'landing.cta.getStarted' | translate }}</span>
    </button>
  `,
  styles: `
    :host {
      display: block;
    }

    button {
      background-color: rgba(255, 255, 255, 0.96);
      padding: 15px 52px;
      border-radius: 50px;
      font-weight: 600;
      font-size: 0.9375rem;
      letter-spacing: 0.01em;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14);
      transition:
        transform 0.2s ease,
        box-shadow 0.2s ease,
        background-color 0.2s ease;

      &:hover {
        background-color: #ffffff;
        cursor: pointer;
        transform: translateY(-2px);
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.22);
      }

      &:active {
        transform: translateY(0);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
      }

      span {
        background: linear-gradient(90deg, #5e23e9 0%, #ca27f3 100%);
        background-clip: text;
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class WhiteButton {
  readonly getStarted = output();
}
