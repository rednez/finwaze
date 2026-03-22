import {
  ChangeDetectionStrategy,
  Component,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Transaction } from '@core/models/transactions';
import { toNameOptions } from '@core/utils/input-transforms';
import { RecentTransactionsWidget } from '@shared/ui/recent-transactions-widget';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-wallet-recent-transactions-card',
  imports: [RecentTransactionsWidget, SelectModule, FormsModule],
  template: `
    <app-recent-transactions-widget
      class="lg:col-span-2"
      [transactions]="transactions()"
      (actionClicked)="backToTransactions.emit()"
    >
      <div extra-actions>
        <p-select
          [ngModel]="currency()"
          (ngModelChange)="currencyChanged.emit($event)"
          [options]="currencies()"
          optionLabel="name"
          optionValue="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '12px',
            },
          }"
        />
      </div>
    </app-recent-transactions-widget>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class WalletRecentTransactionsCard {
  readonly transactions = input<Transaction[]>([]);
  readonly currencies = input<{ name: string }[], string[]>([], {
    transform: toNameOptions,
  });
  readonly initialCurrency = input<string>();
  readonly currencyChanged = output<string>();
  readonly backToTransactions = output<void>();

  protected readonly currency = linkedSignal(() => this.initialCurrency());
}
