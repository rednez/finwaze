import { ComponentFixture, TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';
import { TotalGoalsCard } from './total-goals-card';
import { GoalsListStore } from '../../stores';

describe('TotalGoalsCard', () => {
  let component: TotalGoalsCard;
  let fixture: ComponentFixture<TotalGoalsCard>;

  const mockStore = {
    isLoading: signal(true),
    isUpdating: signal(false),
    totalCount: signal(0),
    notStartedCount: signal(0),
    inProgressCount: signal(0),
    cancelledCount: signal(0),
    doneCount: signal(0),
  };

  beforeEach(async () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    await TestBed.configureTestingModule({
      imports: [TotalGoalsCard],
    })
      .overrideProvider(GoalsListStore, { useValue: mockStore })
      .compileComponents();

    fixture = TestBed.createComponent(TotalGoalsCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show skeleton when loading', () => {
    mockStore.isLoading.set(true);
    fixture.detectChanges();

    const skeleton = fixture.nativeElement.querySelector('p-skeleton');
    expect(skeleton).toBeTruthy();
  });

  it('should show total count when loaded', () => {
    mockStore.isLoading.set(false);
    mockStore.totalCount.set(7);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('7');
  });
});
