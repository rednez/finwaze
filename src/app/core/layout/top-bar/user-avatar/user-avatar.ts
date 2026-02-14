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
    <p-menu #menu [model]="items" [popup]="true" />
    <div
      class="flex gap-2 items-center border border-surface-300 dark:border-surface-600 py-1 pl-1 pr-4 rounded-full"
      (click)="menu.toggle($event)"
    >
      @if (user(); as user) {
        <p-avatar
          class="hidden! sm:block!"
          [image]="user.imgUrl"
          shape="circle"
          size="large"
        />

        <p-avatar class="sm:hidden!" [image]="user.imgUrl" shape="circle" />

        <div>
          <div class="text-sm font-medium">{{ user.name }}</div>
          <div class="text-xs text-gray-400">{{ user.email }}</div>
        </div>
      } @else {
        <p-skeleton shape="circle" size="3rem" />
        <div>
          <p-skeleton width="6rem" height="12px" class="mb-2" />
          <p-skeleton width="6rem" height="12px" />
        </div>
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
