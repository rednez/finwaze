import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  input,
  linkedSignal,
  OnInit,
  output,
} from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-category-chip',
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './category-chip.html',
  host: {
    class:
      'flex items-center gap-2 px-3 h-8 bg-gray-100 dark:bg-gray-900 rounded-xl',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CategoryChip implements OnInit {
  readonly name = input<string>();
  readonly transactionsCount = input(0);
  readonly initialEditingMode = input(false);
  readonly rename = output<string>();
  readonly delete = output();
  readonly cancelEdit = output();

  protected readonly isEditing = linkedSignal(() => this.initialEditingMode());

  protected readonly nameControl = new FormControl('', [
    Validators.required,
    Validators.maxLength(25),
  ]);

  ngOnInit() {
    this.nameControl.setValue(this.name() || '');
  }

  protected onUpdate() {
    if (this.nameControl.valid) {
      this.isEditing.set(false);
      this.rename.emit(this.nameControl.value!);
    }
  }

  protected onCancelEdit() {
    this.isEditing.set(false);
    this.nameControl.setValue(this.name()!);
    this.cancelEdit.emit();
  }
}
