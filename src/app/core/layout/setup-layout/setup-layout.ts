import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TopBar } from '../top-bar';

@Component({
  imports: [RouterOutlet, TopBar],
  template: `
    <app-top-bar [hasTitle]="false" />
    <router-outlet />
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SetupLayout {}
