import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

interface StatisticGroup {
  id: string;
  name: string;
  amount: number;
  color: string;
}

@Component({
  selector: 'app-statistics-by-groups',
  imports: [CommonModule],
  template: `
    @for (group of displayedData(); track group.id) {
      <div class="flex gap-2 justify-between">
        <div class="flex gap-2 items-center">
          <span
            class="block rounded-full size-2"
            [style]="{ backgroundColor: group.color }"
          ></span>
          <span class="text-sm/6">{{ group.name }}</span>
        </div>

        <div class="text-sm  flex gap-4">
          <div class="text-gray-400">
            {{ group.percentage | number: '1.0-0' }}%
          </div>
          <div class="font-medium">
            {{ group.amount | number: '1.0-0' }}
          </div>
        </div>
      </div>
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StatisticsByGroups {
  readonly groups = input<StatisticGroup[]>([]);

  protected readonly displayedData = computed(() => {
    const total = this.groups().reduce((sum, group) => sum + group.amount, 0);

    return this.groups().map((i) => ({
      ...i,
      percentage: (i.amount / total) * 100,
    }));
  });
}
