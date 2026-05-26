import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
  viewChild,
} from '@angular/core';
import { Popover, PopoverModule } from 'primeng/popover';

export const COLOR_PALETTE = [
  '#6366F1',
  '#8B5CF6',
  '#7C3AED',
  '#D946EF',
  '#EC4899',
  '#FB7185',
  '#F43F5E',
  '#F97316',
  '#FB923C',
  '#FBBF24',
  '#F59E0B',
  '#84CC16',
  '#22C55E',
  '#10B981',
  '#14B8A6',
  '#06B6D4',
  '#38BDF8',
  '#3B82F6',
  '#2563EB',
  '#4F46E5',
  '#C4B5FD',
  '#FDBA74',
  '#6EE7B7',
  '#FECDD3',
];

@Component({
  selector: 'app-color-palette',
  imports: [PopoverModule],
  templateUrl: './color-palette.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ColorPalette {
  readonly color = input<string | null>(null);
  readonly colorChange = output<string | null>();

  protected readonly popover = viewChild.required<Popover>('popover');
  protected readonly colors = COLOR_PALETTE;

  protected toggle(event: MouseEvent) {
    event.stopPropagation();
    this.popover().toggle(event);
  }

  protected select(color: string, event: MouseEvent) {
    event.stopPropagation();
    this.colorChange.emit(color);
    this.popover().hide();
  }

  protected clear(event: MouseEvent) {
    event.stopPropagation();
    this.colorChange.emit(null);
    this.popover().hide();
  }
}
