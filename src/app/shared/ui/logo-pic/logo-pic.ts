import { Component } from '@angular/core';

@Component({
  selector: 'app-logo-pic',
  imports: [],
  templateUrl: './pic.svg',
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply block w-24 lg:w-32;
    }
  `,
})
export class LogoPic {}
