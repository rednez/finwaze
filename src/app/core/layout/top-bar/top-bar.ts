import { Component, computed, inject, input, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '@core/services/auth-service';
import { LocalizationService } from '@core/services/localization.service';
import { NavigatorHelper } from '@core/services/navigator-helper';
import { AuthStore } from '@core/store/auth-store';
import { LangSwitcher } from '@shared/ui/lang-switcher';
import { TooltipModule } from '@openng/optimus-ui/tooltip';
import { UserAvatar, UserData } from './user-avatar/user-avatar';

/** App sections that have a title bar and a matching guide article at
 *  /guide/<key>. Single source of truth for the "?" help icon and the
 *  derived page title/description keys. */
const GUIDE_SECTIONS = [
  'dashboard',
  'transactions',
  'categories',
  'wallet',
  'budget',
  'goals',
  'analytics',
] as const;

const SECTIONS_WITH_GUIDE = new Set<string>(GUIDE_SECTIONS);
/** Paths that get a title/description (every guide section, plus the guide hub). */
const TITLED_PATHS = new Set<string>([...GUIDE_SECTIONS, 'guide']);

@Component({
  selector: 'app-top-bar',
  imports: [UserAvatar, LangSwitcher, TooltipModule],
  template: `
    <div>
      @if (hasTitle()) {
        <div class="flex items-center gap-2">
          <h1 class="text-2xl font-display font-medium">{{ title() }}</h1>
          @if (helpTopic(); as topic) {
            <button
              type="button"
              class="flex items-center justify-center text-muted-color hover:text-primary transition-colors cursor-pointer"
              [pTooltip]="sectionHelpLabel()"
              tooltipPosition="bottom"
              [attr.aria-label]="sectionHelpLabel()"
              (click)="goToSectionGuide(topic)"
            >
              <i class="pi pi-question-circle text-lg"></i>
            </button>
          }
        </div>
        <div class="hidden sm:block text-sm text-muted-color">
          {{ description() }}
        </div>
      }
    </div>

    <div class="flex items-center gap-4">
      <app-lang-switcher />
      <app-user-avatar
        [user]="user()"
        (guide)="goToGuide()"
        (settings)="goToSettings()"
        (logout)="logout()"
      />
    </div>
  `,
  host: {
    class: 'flex justify-between gap-1 p-4',
  },
})
export class TopBar {
  readonly hasTitle = input(true);

  private readonly router = inject(Router);
  private readonly navigatorHelper = inject(NavigatorHelper);
  private readonly auth = inject(AuthService);
  private readonly authStore = inject(AuthStore);
  private readonly localizationService = inject(LocalizationService);

  private readonly currentPath = this.navigatorHelper.currentFeatureName;
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly user = signal<UserData | undefined>(undefined);

  protected readonly helpTopic = computed(() => {
    const path = this.currentPath();
    return SECTIONS_WITH_GUIDE.has(path) ? path : null;
  });

  protected readonly sectionHelpLabel = computed(() =>
    this.t('core.sectionHelp'),
  );

  protected readonly title = computed(() => this.pageText('title'));
  protected readonly description = computed(() => this.pageText('description'));

  constructor() {
    this.getUser();
  }

  protected goToGuide() {
    this.router.navigate(['guide']);
  }

  protected goToSectionGuide(topic: string) {
    this.router.navigate(['guide', topic]);
  }

  protected goToSettings() {
    this.router.navigate(['settings']);
  }

  protected async logout() {
    await this.auth.logOut();
  }

  private pageText(field: 'title' | 'description'): string {
    const path = this.currentPath();
    return TITLED_PATHS.has(path) ? this.t(`core.pages.${path}.${field}`) : '';
  }

  private async getUser() {
    const user = this.authStore.user();
    if (user) {
      this.user.set({
        name: user.name,
        email: user.email,
        imgUrl: user.imgUrl,
      });
    }
  }
}
