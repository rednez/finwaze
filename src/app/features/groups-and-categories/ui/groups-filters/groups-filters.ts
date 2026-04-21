import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TransactionType } from '@core/models/transactions';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { FloatLabelModule } from 'primeng/floatlabel';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-groups-filters',
  imports: [
    CommonModule,
    FormsModule,
    SelectModule,
    FloatLabelModule,
    TranslatePipe,
  ],
  templateUrl: './groups-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GroupsFilters {
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly initTransactionType = input<string | null>();
  readonly transactionTypeChanged = output<TransactionType | null>();

  protected readonly transactionTypesOptions = computed(() => [
    { value: 'all', name: this.t('shared.all') },
    { value: 'income', name: this.t('shared.income') },
    { value: 'expense', name: this.t('shared.expense') },
  ]);

  protected readonly selectInputSchema: SelectDesignTokens = {
    root: { borderRadius: '12px' },
  };

  protected selectedTransactionType = linkedSignal(
    () => this.initTransactionType() || 'all',
  );

  protected onTransactionTypeChange(event: string) {
    this.selectedTransactionType.set(event);
    this.transactionTypeChanged.emit(
      event !== 'all' ? (event as TransactionType) : null,
    );
  }
}
