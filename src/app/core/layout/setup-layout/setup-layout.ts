import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TopBar } from '../top-bar';

@Component({
  imports: [RouterOutlet, TopBar],
  template: `
    <app-top-bar [hasTitle]="false" />
    <router-outlet />
  `,
})
export class SetupLayout {}
