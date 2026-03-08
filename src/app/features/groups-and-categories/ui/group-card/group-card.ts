import {
  Component,
  computed,
  input,
  OnInit,
  output,
  signal,
} from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeader } from '@shared/ui/card-header';
import { CardHeaderTitle } from '@shared/ui/card-header-title';
import { ButtonModule } from 'primeng/button';
import { GroupWithCategories } from '../../models';
import { CategoryChip } from '../category-chip';

@Component({
  selector: 'app-group-card',
  imports: [
    ReactiveFormsModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    ButtonModule,
    CategoryChip,
  ],
  styles: `
    @reference "tailwindcss";

    .income {
      @apply text-green-500 dark:text-green-600 bg-green-100 dark:bg-gray-800;
    }
    .expense {
      @apply text-orange-500 dark:text-orange-600 bg-orange-100 dark:bg-gray-800;
    }
  `,
  templateUrl: './group-card.html',
})
export class GroupCard implements OnInit {
  readonly group = input<GroupWithCategories>();
  readonly renameGroup = output<string>();
  readonly deleteGroup = output();
  readonly renameCategory = output<{
    categoryId: number;
    newName: string;
  }>();
  readonly deleteCategory = output<number>();
  readonly createCategory = output<string>();

  protected readonly name = new FormControl('', [
    Validators.required,
    Validators.maxLength(25),
  ]);
  protected readonly isEditing = signal(false);
  protected readonly isCreatingCategory = signal(false);

  protected readonly transactionTypeText = computed(() =>
    this.group()?.transactionType === 'expense' ? 'Expense' : 'Income',
  );

  protected readonly isIncome = computed(
    () => this.group()?.transactionType === 'income',
  );

  protected readonly isExpense = computed(
    () => this.group()?.transactionType === 'expense',
  );

  ngOnInit() {
    this.name.setValue(this.group()?.name || '');
  }

  protected onUpdate() {
    if (this.name.valid) {
      this.isEditing.set(false);
      this.renameGroup.emit(this.name.value!);
    }
  }

  protected cancelEdit() {
    this.isEditing.set(false);
    this.name.setValue(this.group()?.name!);
  }

  protected onRenameCategory(categoryId: number, newCategoryName: string) {
    this.renameCategory.emit({ categoryId, newName: newCategoryName });
  }

  protected onDeleteCategory(categoryId: number) {
    this.deleteCategory.emit(categoryId);
  }

  protected onCreateCategory(categoryName: string) {
    this.createCategory.emit(categoryName);
    this.isCreatingCategory.set(false);
  }
}
