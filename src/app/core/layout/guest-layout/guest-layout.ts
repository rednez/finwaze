import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';

@Component({
  imports: [RouterModule],
  template: ` <router-outlet /> `,
})
export class GuestLayout {}
