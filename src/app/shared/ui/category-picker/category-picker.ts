import { NgTemplateOutlet } from '@angular/common';
import {
  afterNextRender,
  Component,
  computed,
  ElementRef,
  forwardRef,
  inject,
  Injector,
  input,
  model,
  output,
  signal,
  viewChild,
  viewChildren,
} from '@angular/core';
import {
  ControlValueAccessor,
  FormsModule,
  NG_VALUE_ACCESSOR,
} from '@angular/forms';
import { Category, Group } from '@core/models/categories';
import { ResponsiveHelper } from '@core/services/responsive-helper';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ResponsiveOverlay } from '@shared/ui/responsive-overlay';
import { ButtonModule } from '@openng/optimus-ui/button';
import { IconFieldModule } from '@openng/optimus-ui/iconfield';
import { InputIconModule } from '@openng/optimus-ui/inputicon';
import { InputTextModule } from '@openng/optimus-ui/inputtext';

interface CategorySearchResult {
  category: Category;
  groupName: string;
}

/**
 * A single control that picks a group and a category at once: two panes side by
 * side on desktop, a drill-down bottom sheet on mobile. The value is the
 * category id; the owning group is surfaced through `groupId`.
 */
@Component({
  selector: 'app-category-picker',
  imports: [
    NgTemplateOutlet,
    ResponsiveOverlay,
    ButtonModule,
    InputTextModule,
    IconFieldModule,
    InputIconModule,
    FormsModule,
    TranslatePipe,
  ],
  templateUrl: './category-picker.html',
  host: { class: 'block w-full' },
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => CategoryPicker),
      multi: true,
    },
  ],
})
export class CategoryPicker implements ControlValueAccessor {
  readonly label = input<string>();
  readonly inputId = input.required<string>();
  readonly groups = input<Group[]>([]);
  readonly categories = input<Category[]>([]);
  readonly isInvalid = input(false);
  readonly groupId = model<number | null>(null);
  readonly clickAddGroup = output<void>();
  readonly clickAddCategory = output<number>();

  readonly isMobile = inject(ResponsiveHelper).isMobile;

  private readonly injector = inject(Injector);

  protected readonly categoryId = model<number | null>(null);
  protected readonly isDisabled = signal(false);
  protected readonly search = signal('');
  protected readonly activeGroupId = signal<number | null>(null);
  protected readonly isDrilledIn = signal(false);

  /** Callers hand over every category the user owns; only the ones belonging to
   *  `groups` are in scope for this picker (income vs. expense). */
  private readonly scopedCategories = computed(() => {
    const groupIds = new Set(this.groups().map((group) => group.id));

    return this.categories().filter((category) =>
      groupIds.has(category.groupId),
    );
  });

  protected readonly selectedCategory = computed(() =>
    this.categories().find((category) => category.id === this.categoryId()),
  );

  protected readonly selectedGroup = computed(() =>
    this.groups().find((group) => group.id === this.groupId()),
  );

  protected readonly activeGroup = computed(() =>
    this.groups().find((group) => group.id === this.activeGroupId()),
  );

  protected readonly activeCategories = computed(() =>
    this.scopedCategories().filter(
      (category) => category.groupId === this.activeGroupId(),
    ),
  );

  protected readonly query = computed(() => this.search().trim().toLowerCase());

  protected readonly searchResults = computed<CategorySearchResult[]>(() => {
    const query = this.query();

    if (!query) {
      return [];
    }

    return this.scopedCategories()
      .filter((category) => category.name.toLowerCase().includes(query))
      .map((category) => ({
        category,
        groupName: this.groupName(category.groupId),
      }));
  });

  protected readonly triggerClass = computed(() =>
    this.isInvalid()
      ? 'border-[var(--p-form-field-invalid-border-color)]'
      : 'border-surface hover:border-[var(--p-form-field-hover-border-color)]',
  );

  private readonly overlay = viewChild.required(ResponsiveOverlay);
  private readonly groupOptions =
    viewChildren<ElementRef<HTMLElement>>('groupOption');

  private onChange?: (value: number | null) => void;
  private onTouched?: VoidFunction;

  writeValue(categoryId: number | null): void {
    this.categoryId.set(categoryId);
  }

  registerOnChange(fn: (value: number | null) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: VoidFunction): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  protected open(event: Event) {
    const initialGroupId =
      this.groupId() ?? this.selectedCategory()?.groupId ?? null;

    this.search.set('');
    this.activeGroupId.set(initialGroupId ?? this.groups()[0]?.id ?? null);
    this.isDrilledIn.set(!!initialGroupId);
    this.overlay().toggle(event);

    // With a dozen groups the active one is often below the fold on open.
    afterNextRender(
      () => {
        const activeGroupId = String(this.activeGroupId());

        this.groupOptions()
          .find(
            (option) =>
              option.nativeElement.dataset['groupId'] === activeGroupId,
          )
          ?.nativeElement.scrollIntoView({ block: 'nearest' });
      },
      { injector: this.injector },
    );
  }

  protected selectGroup(groupId: number) {
    this.activeGroupId.set(groupId);
    this.isDrilledIn.set(true);
  }

  protected selectCategory(category: Category) {
    this.groupId.set(category.groupId);
    this.categoryId.set(category.id);
    this.onChange?.(category.id);
    this.onTouched?.();
    this.overlay().close();
  }

  protected goBackToGroups() {
    this.isDrilledIn.set(false);
  }

  protected addGroup() {
    this.overlay().close();
    this.clickAddGroup.emit();
  }

  protected addCategory() {
    const groupId = this.activeGroupId();

    if (groupId) {
      this.overlay().close();
      this.clickAddCategory.emit(groupId);
    }
  }

  /** Empty when the group has no colour assigned — callers render no dot then. */
  protected groupColor(groupId: number): string {
    return this.groups().find((group) => group.id === groupId)?.color || '';
  }

  private groupName(groupId: number): string {
    return this.groups().find((group) => group.id === groupId)?.name ?? '';
  }
}
