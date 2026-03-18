import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { TransferDirectionPic } from '@shared/ui/transfer-direction-pic';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { SkeletonModule } from 'primeng/skeleton';
import { ToastModule } from 'primeng/toast';
import { TransferDetailsStore } from '../../store';

@Component({
  imports: [
    CommonModule,
    FormPageLayout,
    ToastModule,
    TransferDirectionPic,
    ButtonModule,
    SkeletonModule,
  ],
  templateUrl: './transfer-details.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class TransferDetails {
  private readonly transferStore = inject(TransferDetailsStore);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly messageService = inject(MessageService);

  protected readonly hasTransaction = computed(
    () => this.transferStore.refTransactions().length > 0,
  );

  protected readonly fromTransaction = computed(() =>
    this.transferStore.refTransactions().find((t) => t.transactionAmount < 0),
  );

  protected readonly fromTransactionAmount = computed(() =>
    this.fromTransaction()
      ? Math.abs(this.fromTransaction()!.transactionAmount)
      : 0,
  );

  protected readonly toTransaction = computed(() =>
    this.transferStore.refTransactions().find((t) => t.transactionAmount > 0),
  );

  protected readonly exchangeRate = computed(() => {
    const from = this.fromTransaction();
    const to = this.toTransaction();

    if (from && to) {
      return Math.abs(to.transactionAmount / from.transactionAmount);
    }

    return null;
  });

  constructor() {
    this.loadData();
  }

  protected gotoBack() {
    this.router.navigate(['transactions']);
  }

  protected async deleteTransfer() {
    const { error } = await this.transferStore.deleteTransfers();

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transfer deletion failed',
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }

  private loadData() {
    const paramId = Number(this.route.snapshot.paramMap.get('id'));

    if (this.transferStore.transactionId() !== paramId) {
      this.transferStore.loadDetails(paramId);
    }
  }
}
