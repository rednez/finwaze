import { Injectable } from '@angular/core';
import { debounceTime, fromEvent, map, startWith } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ResponsiveHelper {
  windowWidth = fromEvent(window, 'resize').pipe(
    debounceTime(50),
    map(() => window.innerWidth),
    startWith(window.innerWidth),
  );
}
