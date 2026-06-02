import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import {
  FormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { passwordsMatchValidator } from '@shared/utils/passwords-match-validator';
import { AuthCard } from '@shared/ui/auth-card/auth-card';
import { ButtonModule } from 'primeng/button';
import { PasswordModule } from 'primeng/password';

@Component({
  imports: [
    ReactiveFormsModule,
    PasswordModule,
    ButtonModule,
    TranslatePipe,
    AuthCard,
  ],
  templateUrl: './change-password.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ChangePassword {
  private readonly formBuilder = inject(FormBuilder);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly auth = inject(AuthService);

  protected form = this.formBuilder.group(
    {
      newPassword: [
        null as string | null,
        [Validators.required, Validators.minLength(8)],
      ],
      confirmPassword: [null as string | null, [Validators.required]],
    },
    { validators: passwordsMatchValidator('newPassword', 'confirmPassword') },
  );

  protected gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  protected onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      this.auth.updatePassword(this.form.value.newPassword!, 'reset');
    }
  }
}
