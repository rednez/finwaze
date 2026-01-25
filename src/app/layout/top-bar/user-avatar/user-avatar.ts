import { Component, input } from '@angular/core';
import { AvatarModule } from 'primeng/avatar';
import { MenuModule } from 'primeng/menu';
import { MenuItem, MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-user-avatar',
  imports: [AvatarModule, MenuModule, ButtonModule],
  template: `
    <p-menu #menu [model]="items" [popup]="true" />
    <div
      class="flex gap-2 items-center border border-gray-300 dark:border-gray-600 py-1 pl-1 pr-4 rounded-full"
      (click)="menu.toggle($event)"
    >
      <p-avatar
        class="hidden! sm:block!"
        [image]="imgUrl()"
        shape="circle"
        size="large"
      />

      <p-avatar class="sm:hidden!" [image]="imgUrl()" shape="circle" />

      <div>
        <div class="text-sm font-medium">{{ name() }}</div>
        <div class="text-xs text-gray-400">{{ email() }}</div>
      </div>
    </div>
  `,
})
export class UserAvatar {
  name = input.required<string>();
  email = input.required<string>();
  // TODO
  imgUrl = input<string>(
    'https://primefaces.org/cdn/primeng/images/demo/avatar/asiyajavayant.png',
  );

  items = [
    {
      label: 'Log out',
      icon: 'pi pi-sign-out',
    },
  ];
}
