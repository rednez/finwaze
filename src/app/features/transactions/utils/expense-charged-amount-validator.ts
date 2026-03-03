import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export const expenseChargedAmountValidator: ValidatorFn = (
  control: AbstractControl,
): ValidationErrors | null => {
  const accountCurrency = control.get('_accountCurrency');
  const transactionAmount = control.get('transactionAmount');
  const transactionCurrency = control.get('transactionCurrency');
  const chargedAmount = control.get('chargedAmount');

  if (
    accountCurrency?.valid &&
    transactionCurrency?.valid &&
    transactionAmount?.valid &&
    accountCurrency?.value !== transactionCurrency?.value &&
    !chargedAmount?.value
  ) {
    return { chargedAmountRequired: true };
  } else if (
    accountCurrency?.valid &&
    transactionCurrency?.valid &&
    transactionAmount?.valid &&
    accountCurrency?.value !== transactionCurrency?.value &&
    transactionAmount.value === chargedAmount!.value
  ) {
    return {
      transactionAndChargedAmountsEquals: true,
    };
  } else {
    return null;
  }
};
