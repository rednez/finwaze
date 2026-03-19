import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from '@core/services/theme.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  template: ` <router-outlet /> `,
})
export class App {
  // Eagerly instantiate ThemeService so the theme is applied before first render
  readonly _theme = inject(ThemeService);
}
