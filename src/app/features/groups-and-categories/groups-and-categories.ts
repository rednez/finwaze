import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TransactionType } from '@core/models/transactions';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';
import { GroupsAndCategoriesStore } from './store';
import { GroupCard } from './ui/group-card';
import { GroupsFilters } from './ui/groups-filters/groups-filters';
import { NewGroupDialog } from './ui/new-group-dialog';
import { EmptyState } from '@shared/ui/empty-state';

@Component({
  imports: [
    GroupCard,
    ToastModule,
    GroupsFilters,
    ButtonModule,
    NewGroupDialog,
    EmptyState,
  ],
  templateUrl: './groups-and-categories.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class GroupsAndCategories {
  protected readonly store = inject(GroupsAndCategoriesStore);
  private readonly messageService = inject(MessageService);

  protected isNewGroupDialogVisible = false;

  constructor() {
    this.store.loadGroups();
  }

  async createGroup($event: {
    name: string;
    transactionType: TransactionType;
  }) {
    const { error } = await this.store.createGroup(
      $event.name,
      $event.transactionType,
    );

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Group creation failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Group created successfully',
      });
    }
  }

  async renameGroup(id: number, name: string) {
    const { error } = await this.store.renameGroup(id, name);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Group renaming failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Group renamed successfully',
      });
    }
  }

  async deleteGroup(id: number) {
    const { error } = await this.store.deleteGroup(id);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Group deletion failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Group deleted successfully',
      });
    }
  }

  async createCategory(name: string, groupId: number) {
    const { error } = await this.store.createCategory(name, groupId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Category creation failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Category created successfully',
      });
    }
  }

  async renameCategory(name: string, categoryId: number, groupId: number) {
    const { error } = await this.store.renameCategory({
      name,
      categoryId,
      groupId,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Category renaming failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Category renamed successfully',
      });
    }
  }

  async deleteCategory(categoryId: number, groupId: number) {
    const { error } = await this.store.deleteCategory(categoryId, groupId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Category deletion failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Category deleted successfully',
      });
    }
  }

  protected onTransactionTypeChanged(event: TransactionType | null) {
    this.store.updateTransactionType(event);
  }
}
