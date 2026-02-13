import { ChangeDetectionStrategy, Component } from '@angular/core';
import { GoogleButton } from './ui/google-button/google-button';
import { LogoShort } from './ui/logo-short/logo-short';

@Component({
  imports: [LogoShort, GoogleButton],
  templateUrl: './login.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {
  protected loginWithGoogle() {
    // TODO
    console.log('Login with Google');
  }
}
