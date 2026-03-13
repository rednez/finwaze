import { Injectable, signal } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class BudgetState {
  readonly isLoadingCategories = signal(false);
  readonly selectedMonth = signal(new Date());
  readonly selectedCurrency = signal('');
  readonly selectedGroupName = signal('');

  reset() {
    this.isLoadingCategories.set(false);
    this.selectedMonth.set(new Date());
    this.selectedCurrency.set('');
    this.selectedGroupName.set('');
  }
}
