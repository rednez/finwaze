import { inject, Service } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router } from '@angular/router';
import { filter, map } from 'rxjs';

@Service()
export class NavigatorHelper {
  private readonly router = inject(Router);

  readonly currentFeatureName = toSignal(
    this.router.events.pipe(
      filter((event) => event instanceof NavigationEnd),
      map(() => this.router.url.split('/')[1]),
    ),
    { initialValue: this.router.url },
  );
}
