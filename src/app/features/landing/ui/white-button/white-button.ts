import { ChangeDetectionStrategy, Component, output } from '@angular/core';

@Component({
  selector: 'app-white-button',
  imports: [],
  template: `
    <button (click)="getStarted.emit()">
      <span>Get Started</span>
    </button>
  `,
  styles: `
    :host {
      display: block;
    }

    button {
      background-color: #fff;
      color: black;
      padding: 16px 48px;
      border-radius: 50px;
      font-weight: 600;
      &:hover {
        background-color: #f0f0f0;
        cursor: pointer;
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
