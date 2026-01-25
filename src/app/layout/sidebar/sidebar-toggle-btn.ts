import { Component, input } from '@angular/core';

@Component({
  selector: 'app-sidebar-toggle-btn',
  imports: [],
  template: `
    <div class="toggle-btn" [class.rotate]="closed()">
      <span class="pi pi-angle-left"></span>
    </div>
  `,
  styles: `
    :host {
      display: block;
      width: fit-content;
    }

    .toggle-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      border: 1px solid light-dark(var(--p-primary-300), var(--p-primary-700));
      height: 26px;
      min-height: 26px;
      width: 26px;
      border-radius: 50px;
      transition: rotate 200ms ease;
      cursor: pointer;
    }

    .rotate {
      rotate: 180deg;
    }
  `,
  host: {
    '[class.rotate]': 'closed()',
  },
})
export class SidebarToggleBtn {
  closed = input(false);
}
