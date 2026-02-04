import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { LogoFullDarkPic } from './full-dark-pic/full-dark-pic';
import { LogoFullLightPic } from './full-light-pic/full-light-pic';
import { LogoShortDarkPic } from './short-dark-pic/short-dark-pic';
import { LogoShortLightPic } from './short-light-pic/short-light-pic';

@Component({
  selector: 'app-logo',
  imports: [
    LogoFullDarkPic,
    LogoFullLightPic,
    LogoShortDarkPic,
    LogoShortLightPic,
  ],
  template: `
    <div class="light">
      <app-logo-full-light-pic
        [class.logo-shown]="!closed()"
        [class.logo-hidden]="closed()"
      />

      <app-logo-short-light-pic
        [class.logo-shown]="closed()"
        [class.logo-hidden]="!closed()"
      />
    </div>

    <div class="dark">
      <app-logo-full-dark-pic
        [class.logo-shown]="!closed()"
        [class.logo-hidden]="closed()"
      />

      <app-logo-short-dark-pic
        [class.logo-shown]="closed()"
        [class.logo-hidden]="!closed()"
      />
    </div>
  `,
  styles: `
    @reference 'tailwindcss';

    :host {
      display: block;
      margin-bottom: 58px;
    }

    .light {
      @apply dark:hidden;
    }

    .dark {
      @apply hidden dark:block;
    }

    .logo-shown {
      display: block;
    }

    .logo-hidden {
      display: none;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Logo {
  readonly closed = input(false);
}
