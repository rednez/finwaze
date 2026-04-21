import {
  ChangeDetectionStrategy,
  Component,
  computed,
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
  selector: 'app-name-prompt-dialog',
  imports: [
    DialogModule,
    ButtonModule,
    InputTextModule,
    ReactiveFormsModule,
    TranslatePipe,
  ],
  template: `
    <p-dialog
      [header]="title()"
      [modal]="true"
      [(visible)]="visible"
      [style]="{ width: '25rem' }"
    >
      <div class="flex flex-col text-start mb-4">
        <label class="text-sm font-medium mb-1" for="name">{{
          'shared.name' | translate
        }}</label>
        <input
          pInputText
          [formControl]="name"
          id="name"
          class="flex-auto"
          autocomplete="off"
          [dt]="{ root: { borderRadius: '16px' } }"
        />
        @if (name.invalid && name.dirty) {
          <div class="text-xs text-red-500 pl-2 pt-0.5">
            @if (name.hasError('required')) {
              {{ 'shared.nameRequired' | translate }}
            } @else if (name.hasError('maxlength')) {
              {{ maxLengthErrorMessage() }}
            }
          </div>
        }
      </div>

      <p-button
        [label]="'shared.create' | translate"
        rounded
        (onClick)="onCreateClick()"
      />
    </p-dialog>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NamePromptDialog {
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly title = input('');
  readonly maxLength = input(25);
  readonly clickSave = output<string>();
  readonly visible = model(false);

  protected readonly name = new FormControl('', [
    Validators.required,
    Validators.maxLength(this.maxLength()),
  ]);

  protected readonly maxLengthErrorMessage = computed(() =>
    this.t('shared.maxLength').replace('{{n}}', String(this.maxLength())),
  );

  protected async onCreateClick() {
    this.name.markAsDirty();
    if (this.name.valid) {
      this.clickSave.emit(this.name.value!);
      this.name.reset();
      this.visible.set(false);
    }
  }
}
