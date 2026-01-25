import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BottomNavBar, Sidebar, TopBar } from '@layout';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Sidebar, TopBar, BottomNavBar],
  template: `
    <app-sidebar />

    <app-bottom-nav-bar />

    <div class="grow min-w-0">
      <app-top-bar />

      <div class="px-4 pb-4">
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
