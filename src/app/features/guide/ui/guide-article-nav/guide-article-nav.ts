import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { GuideTopicLink } from '../../models';

@Component({
  selector: 'app-guide-article-nav',
  imports: [RouterLink, ButtonModule],
  template: `
    <nav class="flex items-center justify-between gap-4">
      @if (prev(); as prev) {
        <a [routerLink]="['/guide', prev.key]" class="min-w-0">
          <p-button severity="secondary" text rounded>
            <i class="pi pi-arrow-left"></i>
            <span class="truncate">{{ prev.title }}</span>
          </p-button>
        </a>
      } @else {
        <span></span>
      }
      @if (next(); as next) {
        <a [routerLink]="['/guide', next.key]" class="min-w-0">
          <p-button rounded>
            <span class="truncate">{{ next.title }}</span>
            <i class="pi pi-arrow-right"></i>
          </p-button>
        </a>
      } @else {
        <a routerLink="/guide">
          <p-button rounded>
            {{ backLabel() }}
            <i class="pi pi-th-large"></i>
          </p-button>
        </a>
      }
    </nav>
  `,
})
export class GuideArticleNav {
  readonly prev = input.required<GuideTopicLink | null>();
  readonly next = input.required<GuideTopicLink | null>();
  /** Fallback label shown on the last article, linking back to the hub. */
  readonly backLabel = input.required<string>();
}
