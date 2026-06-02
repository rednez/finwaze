import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '@core/services/auth-service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { passwordsMatchValidator } from '@shared/utils/passwords-match-validator';
import { ButtonModule } from 'primeng/button';
import { PasswordModule } from 'primeng/password';

@Component({
  selector: 'app-update-password',
  imports: [ReactiveFormsModule, PasswordModule, ButtonModule, TranslatePipe],
  templateUrl: './update-password.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UpdatePassword {
  private readonly formBuilder = inject(FormBuilder);
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

  protected async onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      await this.auth.updatePassword(this.form.value.newPassword!, 'update');
    }
  }
}
