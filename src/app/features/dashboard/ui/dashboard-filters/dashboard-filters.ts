import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  model,
  OnInit,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { IftaLabelModule } from 'primeng/iftalabel';
import { MultiSelectModule } from 'primeng/multiselect';
import { SelectChangeEvent, SelectModule } from 'primeng/select';

@Component({
  selector: 'app-dashboard-filters',
  imports: [FormsModule, SelectModule, IftaLabelModule, MultiSelectModule],
  templateUrl: './dashboard-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex gap-2 flex-wrap',
  },
})
export class DashboardFilters implements OnInit {
  readonly currencies = input<string[]>([]);
  readonly initCurrency = input<string>();
  readonly currencyChanged = output<string>();

  protected selectedCurrency: { name: string } = model();

  protected readonly currenciesOptions = computed(() =>
    this.currencies().map((name) => ({ name })),
  );

  ngOnInit(): void {
    if (this.initCurrency()) {
      this.selectedCurrency = { name: this.initCurrency()! };
    }
  }

  protected onChange($event: SelectChangeEvent) {
    this.currencyChanged.emit($event.value.name);
  }
}
