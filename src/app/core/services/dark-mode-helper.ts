import { Injectable, Signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { fromEvent, map, Observable, startWith } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class DarkModeHelper {
  readonly isDarkModeChanges$: Observable<boolean>;
  readonly isDark: Signal<boolean>;

  constructor() {
    const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');

    this.isDarkModeChanges$ = fromEvent<MediaQueryListEvent>(
      darkModeQuery,
      'change',
    ).pipe(
      map((e) => e.matches),
      startWith(darkModeQuery.matches),
    );

    this.isDark = toSignal(this.isDarkModeChanges$, {
      initialValue: darkModeQuery.matches,
    });
  }
}
