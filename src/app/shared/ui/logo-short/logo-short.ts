import { Component } from '@angular/core';

@Component({
  selector: 'app-logo-short',
  templateUrl: './pic.svg',
  styles: `
    :host {
      display: block;
      height: 52px;
    }
  `,
})
export class LogoShort {}
