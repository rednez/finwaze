import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TransactionType } from '@core/models/transactions';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { EmptyState } from '@shared/ui/empty-state';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';
import { GroupsAndCategoriesStore } from './store';
import { GroupCard } from './ui/group-card';
import { GroupsFilters } from './ui/groups-filters/groups-filters';
import { NewGroupDialog } from './ui/new-group-dialog';

@Component({
  imports: [
    GroupCard,
    ToastModule,
    GroupsFilters,
    ButtonModule,
    NewGroupDialog,
    EmptyState,
    TranslatePipe,
  ],
  templateUrl: './groups-and-categories.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class GroupsAndCategories {
  protected readonly store = inject(GroupsAndCategoriesStore);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

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
        summary: this.t('groups.groupCreationFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.groupCreatedSuccessfully'),
      });
    }
  }

  async renameGroup(id: number, name: string) {
    const { error } = await this.store.renameGroup(id, name);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('groups.groupRenamingFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.groupRenamedSuccessfully'),
      });
    }
  }

  async deleteGroup(id: number) {
    const { error } = await this.store.deleteGroup(id);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('groups.groupDeletionFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.groupDeletedSuccessfully'),
      });
    }
  }

  async createCategory(name: string, groupId: number) {
    const { error } = await this.store.createCategory(name, groupId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('groups.categoryCreationFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.categoryCreatedSuccessfully'),
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
        summary: this.t('groups.categoryRenamingFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.categoryRenamedSuccessfully'),
      });
    }
  }

  async deleteCategory(categoryId: number, groupId: number) {
    const { error } = await this.store.deleteCategory(categoryId, groupId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('groups.categoryDeletionFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: this.t('groups.categoryDeletedSuccessfully'),
      });
    }
  }

  protected onTransactionTypeChanged(event: TransactionType | null) {
    this.store.updateTransactionType(event);
  }
}
