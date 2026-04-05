import { ComponentFixture, TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';
import { SavingsOverviewStore } from '../../stores/savings-overview-store';
import { SavingsOverviewWidget } from './savings-overview-widget';

describe('SavingsOverviewWidget', () => {
  let component: SavingsOverviewWidget;
  let fixture: ComponentFixture<SavingsOverviewWidget>;

  const mockStore = {
    isLoading: signal(false),
    isLoaded: signal(true),
    isError: signal(false),
    labels: signal<string[]>([]),
    currentSavings: signal<number[]>([]),
    previousSavings: signal<number[]>([]),
    selectedYear: signal(new Date()),
    selectedCurrencyCode: signal('USD'),
    load: vi.fn().mockResolvedValue(undefined),
    updateYear: vi.fn(),
    updateCurrencyCode: vi.fn(),
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
      imports: [SavingsOverviewWidget],
    })
      .overrideProvider(SavingsOverviewStore, { useValue: mockStore })
      .compileComponents();

    fixture = TestBed.createComponent(SavingsOverviewWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
