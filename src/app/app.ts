import { Component, inject } from '@angular/core';
import { Analytics } from '@angular/fire/analytics';
import { RouterOutlet } from '@angular/router';
import { ThemeService } from '@core/services/theme.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  template: ` <router-outlet /> `,
})
export class App {
  readonly _theme = inject(ThemeService);
  readonly _analytics = inject(Analytics, { optional: true });
}
