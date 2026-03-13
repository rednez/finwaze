import { Component } from '@angular/core';

@Component({
  selector: 'app-section-spending-pic',
  templateUrl: './pic.svg',
  styles: `
    :host {
      display: block;
      height: 192px;
      width: 192px;
    }
  `,
})
export class SectionSpendingPic {}
