import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

@Component({
  selector: 'app-testimonial-card',
  imports: [],
  template: `
    <div class="flex gap-0.5 mb-5">
      @for (star of stars; track $index) {
        <span class="text-amber-400 text-sm leading-none">★</span>
      }
    </div>

    <p
      class="text-sm text-gray-600 dark:text-gray-300 leading-relaxed flex-1 mb-6"
    >
      "{{ quote() }}"
    </p>

    <div class="flex items-center gap-3">
      <div class="avatar">{{ initials() }}</div>
      <div>
        <div class="text-sm font-semibold text-gray-800 dark:text-gray-100">
          {{ author() }}
        </div>
        <div class="text-xs text-gray-400 dark:text-gray-500 mt-0.5">
          {{ role() }}
        </div>
      </div>
    </div>
  `,
  host: {
    class: 'flex flex-col flex-1',
  },
  styles: `
    :host {
      padding: 28px;
      border-radius: 24px;
      background: light-dark(#ffffff, var(--p-surface-800));
      border: 1px solid light-dark(#f0f0f6, rgba(255, 255, 255, 0.05));
      box-shadow: 0 4px 24px
        light-dark(rgba(94, 35, 233, 0.06), rgba(0, 0, 0, 0.18));
      transition:
        box-shadow 0.25s ease,
        transform 0.25s ease;
    }

    :host:hover {
      box-shadow: 0 8px 36px
        light-dark(rgba(94, 35, 233, 0.1), rgba(0, 0, 0, 0.26));
      transform: translateY(-2px);
    }

    .avatar {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: linear-gradient(135deg, #7c3aed, #ca27f3);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 0.7rem;
      font-weight: 700;
      flex-shrink: 0;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TestimonialCard {
  readonly quote = input('');
  readonly author = input('');
  readonly role = input('');

  protected readonly stars = [1, 2, 3, 4, 5];

  protected readonly initials = computed(() =>
    this.author()
      .split(' ')
      .map((n) => n[0])
      .join(''),
  );
}
