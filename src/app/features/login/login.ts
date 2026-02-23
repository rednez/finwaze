import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { AuthService } from '@core/services/auth-service';
import { DemoButton } from './ui/demo-button/demo-button';
import { GoogleButton } from './ui/google-button/google-button';
import { LogoShort } from './ui/logo-short/logo-short';

@Component({
  imports: [LogoShort, GoogleButton, DemoButton],
  templateUrl: './login.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {
  private readonly auth = inject(AuthService);

  protected loginWithGoogle() {
    this.auth.loginWithGoogle();
  }

  protected async loginWithDemo() {
    await this.auth.loginWithDemo();
  }
}
