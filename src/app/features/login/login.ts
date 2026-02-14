import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';
import { GoogleButton } from './ui/google-button/google-button';
import { LogoShort } from './ui/logo-short/logo-short';

@Component({
  imports: [LogoShort, GoogleButton],
  templateUrl: './login.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Login {
  private supabase = inject(SupabaseService);

  protected async loginWithGoogle() {
    this.supabase.signInWithGoogle();
  }
}
