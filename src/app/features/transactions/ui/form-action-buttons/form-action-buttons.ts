import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-form-action-buttons',
  imports: [ButtonModule, TranslatePipe],
  templateUrl: './form-action-buttons.html',
  host: {
    class: 'mt-8 flex justify-between',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormActionButtons {
  readonly isCreatingMode = input(false);
  readonly isSubmitting = input(false);
  readonly clickSubmit = output();
  readonly clickDelete = output();
}
