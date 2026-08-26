import { computed, Service } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { debounceTime, fromEvent, map, startWith } from 'rxjs';

/** Matches Tailwind's `sm` breakpoint, the point where the app switches to the
 *  stacked, touch-first layout. */
const MOBILE_BREAKPOINT = 640;

@Service()
export class ResponsiveHelper {
  windowWidth = fromEvent(window, 'resize').pipe(
    debounceTime(50),
    map(() => window.innerWidth),
    startWith(window.innerWidth),
  );

  private readonly width = toSignal(this.windowWidth, {
    initialValue: window.innerWidth,
  });

  readonly isMobile = computed(() => this.width() < MOBILE_BREAKPOINT);
}
