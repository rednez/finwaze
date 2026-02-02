import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BottomNavBar } from '@layout/bottom-nav-bar';
import { Sidebar } from '@layout/sidebar';
import { TopBar } from '@layout/top-bar';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Sidebar, TopBar, BottomNavBar],
  template: `
    <app-sidebar />

    <app-bottom-nav-bar />

    <div class="grow min-w-0">
      <app-top-bar />

      <div class="px-4 pb-24 sm:pb-4">
        <router-outlet />
      </div>
    </div>
  `,
  host: {
    class: 'flex',
  },
})
export class App {
  visible = signal(false);
}
