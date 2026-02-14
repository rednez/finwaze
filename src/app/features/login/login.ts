import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { SupabaseService } from '@core/services/supabase.service';
import { DemoButton } from './ui/demo-button/demo-button';
import { GoogleButton } from './ui/google-button/google-button';
import { LogoShort } from './ui/logo-short/logo-short';

@Component({
  imports: [LogoShort, GoogleButton, DemoButton],
  templateUrl: './login.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {
  private readonly supabase = inject(SupabaseService);
  private readonly router = inject(Router);

  protected loginWithGoogle() {
    this.supabase.signInWithGoogle();
  }

  protected async loginWithDemo() {
    await this.supabase.signInWithDemo();
    this.router.navigate(['dashboard']);
  }
}
