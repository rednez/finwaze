import { Component, input } from '@angular/core';
import { AvatarModule } from 'primeng/avatar';

@Component({
  selector: 'app-user-avatar',
  imports: [AvatarModule],
  template: `<p-avatar [image]="imgUrl()" shape="circle" size="large" />
    <div>
      <div class="text-sm font-medium">{{ name() }}</div>
      <div class="text-xs text-gray-400">{{ email() }}</div>
    </div>`,
  host: {
    class:
      'flex gap-2 items-center border-1 border-gray-300 dark:border-gray-600 pl-1 pr-4 rounded-full',
  },
})
export class UserAvatar {
  name = input.required<string>();
  email = input.required<string>();
  imgUrl = input<string>('https://primefaces.org/cdn/primeng/images/demo/avatar/asiyajavayant.png');
}
