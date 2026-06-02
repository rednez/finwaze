import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AuthCard } from '@shared/ui/auth-card/auth-card';
import { AuthRedirectLink } from '@shared/ui/auth-redirect-link/auth-redirect-link';
import { DemoButton } from './ui/demo-button/demo-button';
import { EmailAuthButton } from './ui/email-auth-button/email-auth-button';
import { GoogleButton } from './ui/google-button/google-button';
import { PasskeyButton } from './ui/passkey-button/passkey-button';

@Component({
  imports: [
    AuthCard,
    AuthRedirectLink,
    GoogleButton,
    DemoButton,
    EmailAuthButton,
    PasskeyButton,
    TranslatePipe,
  ],
  templateUrl: './login.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  protected loginWithGoogle() {
    this.auth.loginWithGoogle();
  }

  protected async loginWithDemo() {
    await this.auth.loginWithDemo();
  }

  protected async loginWithPasskey() {
    await this.auth.loginWithPasskey();
  }

  protected goToSignIn() {
    this.router.navigate(['signin']);
  }
}
