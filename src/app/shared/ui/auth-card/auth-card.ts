import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { LogoShort } from '@shared/ui/logo-short/logo-short';
import { ToastModule } from 'primeng/toast';

@Component({
  selector: 'app-auth-card',
  imports: [LogoShort, ToastModule],
  template: `
    <p-toast />

    <div
      class="relative min-h-screen flex flex-col items-center justify-center p-6"
    >
      <div
        class="w-full max-w-110 bg-white/40 dark:bg-zinc-900/40 backdrop-blur-2xl border border-white dark:border-zinc-800/50 p-4 sm:p-10 rounded-[40px] shadow-2xl shadow-violet-500/12 dark:shadow-none"
      >
        @if (showLogo()) {
          <div class="flex justify-center mb-8">
            <div class="relative">
              <app-logo-short />
            </div>
          </div>
        }

        <div class="text-center mb-10">
          <h1
            class="font-display text-3xl font-semibold tracking-tight leading-tight"
            [class.hidden]="!title()"
          >
            {{ title() }}
          </h1>
          <p
            class="text-slate-500 dark:text-zinc-400 mt-3 font-light leading-relaxed"
            [class.hidden]="!subtitle()"
          >
            {{ subtitle() }}
          </p>
        </div>

        <ng-content />
      </div>
    </div>
  `,
  host: {
    class:
      'bg-[#FDFDFF] dark:bg-[#09090B] text-slate-900 dark:text-zinc-100 transition-colors duration-500 overflow-hidden',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AuthCard {
  readonly showLogo = input(true);
  readonly title = input<string>();
  readonly subtitle = input<string>();
}
