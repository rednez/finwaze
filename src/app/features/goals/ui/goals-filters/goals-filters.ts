import {
  ChangeDetectionStrategy,
  Component,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DatePickerModule } from 'primeng/datepicker';
import { FloatLabelModule } from 'primeng/floatlabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-goals-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    DatePickerModule,
    FloatLabelModule,
  ],
  templateUrl: './goals-filters.html',
  host: {
    class: 'flex gap-2 flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalsFilters {
  protected readonly statuses = signal([
    { name: 'All' },
    { name: 'Not started' },
    { name: 'In progress' },
    { name: 'Done' },
    { name: 'Canceled' },
  ]);

  protected year = new Date();
  protected status: { name: string } = model({ name: 'All' });
}
