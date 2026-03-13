import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-gradient-block',
  imports: [],
  template: ` <ng-content /> `,
  styles: `
    :host {
      display: block;
      padding: 44px 40px;
      border-radius: 28px;
      color: #fff;
      background: linear-gradient(
        135deg,
        #5e23e9 0%,
        #8b2be8 45%,
        #ca27f3 100%
      );
      box-shadow:
        0 20px 60px rgba(94, 35, 233, 0.28),
        0 4px 16px rgba(94, 35, 233, 0.14);
      position: relative;
      overflow: hidden;
    }

    :host::before {
      content: '';
      position: absolute;
      top: -50%;
      left: -5%;
      width: 55%;
      height: 220%;
      background: radial-gradient(
        ellipse,
        rgba(255, 255, 255, 0.13) 0%,
        transparent 65%
      );
      pointer-events: none;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GradientBlock {}
