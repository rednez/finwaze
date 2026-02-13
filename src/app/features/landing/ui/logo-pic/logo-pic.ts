import { Component } from '@angular/core';

@Component({
  selector: 'app-logo-pic',
  imports: [],
  templateUrl: './pic.svg',
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply block w-50;
    }
  `,
})
export class LogoPic {}
