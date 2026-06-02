import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * Builds a group-level validator that flags a `passwordsMismatch` error when
 * the password and its confirmation differ. The control names are
 * configurable so it can be reused across forms (e.g. `password` on sign-up,
 * `newPassword` on password change).
 */
export function passwordsMatchValidator(
  passwordKey = 'password',
  confirmPasswordKey = 'confirmPassword',
): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const password = control.get(passwordKey)?.value;
    const confirmPassword = control.get(confirmPasswordKey)?.value;

    if (!password || !confirmPassword || password === confirmPassword) {
      return null;
    }

    return { passwordsMismatch: true };
  };
}
