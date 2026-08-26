import { NgTemplateOutlet } from '@angular/common';
import {
  Component,
  computed,
  inject,
  input,
  signal,
  viewChild,
} from '@angular/core';
import { ResponsiveHelper } from '@core/services/responsive-helper';
import { DrawerModule } from '@openng/optimus-ui/drawer';
import { Popover, PopoverModule } from '@openng/optimus-ui/popover';

/**
 * Renders the projected content as an anchored popover on desktop and as a
 * bottom sheet on mobile. The trigger stays with the host component, which
 * drives the overlay through `toggle()` / `close()`.
 */
@Component({
  selector: 'app-responsive-overlay',
  imports: [NgTemplateOutlet, DrawerModule, PopoverModule],
  template: `
    @if (isMobile()) {
      <p-drawer
        appendTo="body"
        [position]="sheetPosition()"
        [header]="header()"
        [visible]="opened()"
        (visibleChange)="opened.set($event)"
        [style]="sheetStyle()"
      >
        <div class="pb-[max(0.5rem,env(safe-area-inset-bottom))]">
          <ng-container [ngTemplateOutlet]="body" />
        </div>
      </p-drawer>
    } @else {
      <p-popover
        #popover
        appendTo="body"
        [style]="popoverStyle"
        (onShow)="opened.set(true)"
        (onHide)="opened.set(false)"
      >
        <ng-container [ngTemplateOutlet]="body" />
      </p-popover>
    }

    <ng-template #body><ng-content /></ng-template>
  `,
})
export class ResponsiveOverlay {
  readonly header = input('');
  /** `full` gives a full-screen sheet, for content that needs the whole viewport. */
  readonly sheetPosition = input<'bottom' | 'full'>('bottom');

  readonly isMobile = inject(ResponsiveHelper).isMobile;

  protected readonly opened = signal(false);
  readonly isOpen = this.opened.asReadonly();

  protected readonly sheetStyle = computed(() =>
    this.sheetPosition() === 'full'
      ? {}
      : {
          height: 'auto',
          maxHeight: '85dvh',
          borderTopLeftRadius: '1.75rem',
          borderTopRightRadius: '1.75rem',
        },
  );
  protected readonly popoverStyle = { padding: '0.375rem' };

  private readonly popover = viewChild<Popover>('popover');

  toggle(event: Event) {
    if (this.isMobile()) {
      this.opened.update((opened) => !opened);
    } else {
      this.popover()?.toggle(event);
    }
  }

  close() {
    if (this.isMobile()) {
      this.opened.set(false);
    } else {
      this.popover()?.hide();
    }
  }
}
