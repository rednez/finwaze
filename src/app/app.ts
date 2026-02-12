import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BottomNavBar } from '@core/layout/bottom-nav-bar';
import { Sidebar } from '@core/layout/sidebar';
import { TopBar } from '@core/layout/top-bar';

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
export class App {}
