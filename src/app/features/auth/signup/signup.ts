import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AuthCard } from '@shared/ui/auth-card/auth-card';
import { AuthRedirectLink } from '@shared/ui/auth-redirect-link/auth-redirect-link';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';

function passwordsMatchValidator(
  control: AbstractControl,
): ValidationErrors | null {
  const password = control.get('password')?.value;
  const confirmPassword = control.get('confirmPassword')?.value;

  if (!password || !confirmPassword || password === confirmPassword) {
    return null;
  }

  return { passwordsMismatch: true };
}

@Component({
  imports: [
    AuthCard,
    AuthRedirectLink,
    ReactiveFormsModule,
    InputTextModule,
    PasswordModule,
    ButtonModule,
    TranslatePipe,
  ],
  templateUrl: './signup.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Signup {
  private readonly formBuilder = inject(FormBuilder);
  private readonly auth = inject(AuthService);

  protected readonly emailSent = this.auth.isConfirmationEmailSent;

  protected form = this.formBuilder.group(
    {
      email: [null as string | null, [Validators.required, Validators.email]],
      password: [
        null as string | null,
        [Validators.required, Validators.minLength(6)],
      ],
      confirmPassword: [null as string | null, [Validators.required]],
    },
    { validators: passwordsMatchValidator },
  );

  protected async onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      await this.auth.signUp({
        email: this.form.value.email as string,
        password: this.form.value.password as string,
      });
    }
  }
}
