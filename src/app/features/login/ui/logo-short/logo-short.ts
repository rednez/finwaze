import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-logo-short',
  templateUrl: './pic.svg',
  styles: `
    :host {
      display: block;
      height: 60px;
    }
  `,
})
export class LogoShort {}
