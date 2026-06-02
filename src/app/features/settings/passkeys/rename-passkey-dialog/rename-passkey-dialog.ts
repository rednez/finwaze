import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
  inject,
  input,
  model,
  output,
} from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';

@Component({
  selector: 'app-rename-passkey-dialog',
  imports: [
    DialogModule,
    ButtonModule,
    InputTextModule,
    ReactiveFormsModule,
    TranslatePipe,
  ],
  template: `
    <p-dialog
      [header]="'settings.passkeys.renameDialog.header' | translate"
      [modal]="true"
      [(visible)]="visible"
      [style]="{ width: '25rem' }"
    >
      <div class="flex flex-col text-start mb-6">
        <label class="text-sm font-medium mb-1" for="passkeyName">
          {{ 'settings.passkeys.renameDialog.label' | translate }}
        </label>
        <input
          pInputText
          [formControl]="name"
          id="passkeyName"
          class="flex-auto"
          autocomplete="off"
          [dt]="{ root: { borderRadius: '16px' } }"
        />
        @if (name.invalid && name.dirty) {
          <div class="text-xs text-red-500 pl-2 pt-0.5">
            @if (name.hasError('required')) {
              {{ 'settings.passkeys.renameDialog.required' | translate }}
            } @else if (name.hasError('maxlength')) {
              {{ maxLengthErrorMessage() }}
            }
          </div>
        }
      </div>

      <p-button
        [label]="'shared.save' | translate"
        rounded
        (onClick)="onSave()"
      />
    </p-dialog>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RenamePasskeyDialog {
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly visible = model(false);
  readonly currentName = input<string>('');
  readonly renamed = output<string>();

  protected readonly name = new FormControl('', [
    Validators.required,
    Validators.maxLength(60),
  ]);

  protected readonly maxLengthErrorMessage = computed(() =>
    this.t('shared.maxLength').replace('{{n}}', '60'),
  );

  constructor() {
    // Seed the input with the current name each time the dialog opens.
    effect(() => {
      if (this.visible()) {
        this.name.setValue(this.currentName(), { emitEvent: false });
      }
    });
  }

  protected onSave() {
    this.name.markAsDirty();

    if (this.name.valid) {
      this.renamed.emit(this.name.value!.trim());
      this.visible.set(false);
    }
  }
}
