import { Component, input, output } from '@angular/core';

@Component({
  selector: 'app-sidebar-nav-item',
  imports: [],
  template: `<li [class.active]="active()" [class.closed]="closed()">
    <span class="material-icons-outlined"> {{ icon() }} </span>
    <span class="nav-label" [class.closed]="closed()">{{ label() }}</span>
  </li>`,
  styles: `
    li {
      padding: 12px 8px;
      border-radius: 22px;
      display: flex;
      align-items: center;
      gap: 16px;

      &:hover {
        background-color: light-dark(var(--p-primary-100), var(--p-gray-700));
        cursor: pointer;
      }

      &.active {
        background-color: var(--p-primary-color);
        color: white;
      }

      .nav-label {
        transition: opacity 200ms ease-in-out;
        &.closed {
          opacity: 0;
        }
      }
    }
  `,
})
export class SidebarNavItem {
  label = input.required<string>();
  icon = input.required<string>();
  active = input(false);
  closed = input(false);
}
