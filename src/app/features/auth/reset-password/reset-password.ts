import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AuthCard } from '@shared/ui/auth-card/auth-card';
import { AuthRedirectLink } from '@shared/ui/auth-redirect-link/auth-redirect-link';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';

@Component({
  imports: [
    AuthCard,
    AuthRedirectLink,
    ReactiveFormsModule,
    InputTextModule,
    ButtonModule,
    TranslatePipe,
  ],
  templateUrl: './reset-password.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ResetPassword {
  private readonly formBuilder = inject(FormBuilder);
  private readonly auth = inject(AuthService);

  protected submitted = signal(false);

  protected form = this.formBuilder.group({
    email: [null as string | null, [Validators.required, Validators.email]],
  });

  protected async onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      await this.auth.resetPasswordForEmail(this.form.value.email as string);
      this.submitted.set(true);
    }
  }
}
