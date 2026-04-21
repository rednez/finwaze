import {
  ChangeDetectionStrategy,
  Component,
  input,
  model,
  OnInit,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { toNameOptions } from '@core/utils/input-transforms';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { FloatLabelModule } from 'primeng/floatlabel';
import { MultiSelectModule } from 'primeng/multiselect';
import { SelectChangeEvent, SelectModule } from 'primeng/select';

@Component({
  selector: 'app-dashboard-filters',
  imports: [
    FormsModule,
    SelectModule,
    FloatLabelModule,
    MultiSelectModule,
    TranslatePipe,
  ],
  templateUrl: './dashboard-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex gap-2 flex-wrap',
  },
})
export class DashboardFilters implements OnInit {
  readonly currencies = input<{ name: string }[], string[]>([], {
    transform: toNameOptions,
  });
  readonly initCurrency = input<string>();
  readonly currencyChanged = output<string>();

  protected selectedCurrency: { name: string } = model();

  ngOnInit(): void {
    if (this.initCurrency()) {
      this.selectedCurrency = { name: this.initCurrency()! };
    }
  }

  protected onChange($event: SelectChangeEvent) {
    this.currencyChanged.emit($event.value.name);
  }
}
