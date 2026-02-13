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
      padding: 16px 48px;
      color: #fff;
      font-weight: 600;

      &:hover {
        cursor: pointer;
        opacity: 0.95;
      }
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GradientButton {
  readonly getStarted = output();
}
