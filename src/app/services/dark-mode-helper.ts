import { Injectable } from '@angular/core';
import { fromEvent, map, Observable, startWith } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class DarkModeHelper {
  readonly isDarkModeChanges$: Observable<boolean>;

  constructor() {
    const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');

    this.isDarkModeChanges$ = fromEvent<MediaQueryListEvent>(
      darkModeQuery,
      'change',
    ).pipe(
      map((e) => e.matches),
      startWith(darkModeQuery.matches),
    );
  }

  isDarkMode(): boolean {
    const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
    return darkModeQuery.matches;
  }
}
