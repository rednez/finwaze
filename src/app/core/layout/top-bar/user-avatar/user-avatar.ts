import { Component, input, output } from '@angular/core';
import { AvatarModule } from 'primeng/avatar';
import { ButtonModule } from 'primeng/button';
import { MenuModule } from 'primeng/menu';
import { SkeletonModule } from 'primeng/skeleton';

export interface UserData {
  name?: string;
  email?: string;
  imgUrl?: string;
}

@Component({
  selector: 'app-user-avatar',
  imports: [AvatarModule, MenuModule, ButtonModule, SkeletonModule],
  template: `
    <p-menu #menu [model]="items" [popup]="true">
      <ng-template #start>
        @if (user(); as user) {
          <div
            class="p-4 border-b border-b-surface-100 dark:border-b-surface-700"
          >
            <div class="text-sm font-medium">{{ user.name }}</div>
            <div class="text-xs text-gray-500">{{ user.email }}</div>
          </div>
        }
      </ng-template>
    </p-menu>
    <div
      class="flex gap-2 items-center border-2 border-surface-200 dark:border-surface-700 p-0.5 rounded-full"
      role="button"
      tabindex="0"
      (click)="menu.toggle($event)"
      (keydown.enter)="menu.toggle($event)"
      (keydown.space)="menu.toggle($event)"
    >
      @if (user(); as user) {
        <p-avatar
          class="hidden! sm:block!"
          [image]="user.imgUrl"
          shape="circle"
          size="large"
        />

        <p-avatar class="sm:hidden!" [image]="user.imgUrl" shape="circle" />
      } @else {
        <p-skeleton shape="circle" size="3rem" />
      }
    </div>
  `,
})
export class UserAvatar {
  readonly user = input<UserData | undefined>(undefined);
  readonly logout = output();

  protected items = [
    {
      label: 'Log out',
      icon: 'pi pi-sign-out',
      command: () => this.logout.emit(),
    },
  ];
}
