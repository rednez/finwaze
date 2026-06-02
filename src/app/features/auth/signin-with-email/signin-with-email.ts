import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AuthCard } from '@shared/ui/auth-card/auth-card';
import { AuthRedirectLink } from '@shared/ui/auth-redirect-link/auth-redirect-link';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';

@Component({
  imports: [
    AuthCard,
    AuthRedirectLink,
    RouterLink,
    ReactiveFormsModule,
    InputTextModule,
    PasswordModule,
    ButtonModule,
    TranslatePipe,
  ],
  templateUrl: './signin-with-email.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SigninWithEmail {
  private readonly formBuilder = inject(FormBuilder);
  private readonly auth = inject(AuthService);

  protected form = this.formBuilder.group({
    email: [null as string | null, [Validators.required, Validators.email]],
    password: [null as string | null, [Validators.required]],
  });

  protected async onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      await this.auth.loginWithEmail({
        email: this.form.value.email as string,
        password: this.form.value.password as string,
      });
    }
  }
}
