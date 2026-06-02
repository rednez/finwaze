import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-auth-redirect-link',
  imports: [RouterLink],
  template: `
    <div class="mt-8 text-center text-sm text-slate-500 dark:text-zinc-400">
      {{ prompt() }}
      <a
        [routerLink]="link()"
        class="text-violet-600 dark:text-violet-400 font-medium hover:underline"
      >
        {{ linkLabel() }}
      </a>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AuthRedirectLink {
  readonly prompt = input.required<string>();
  readonly linkLabel = input.required<string>();
  readonly link = input.required<string>();
}
