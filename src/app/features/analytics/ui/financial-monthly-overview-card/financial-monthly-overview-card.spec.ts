import { signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DailyDataPoint } from '../../models';
import { AnalyticsStore } from '../../stores';
import { FinancialMonthlyOverviewCard } from './financial-monthly-overview-card';

const makeDataPoints = (offset = 0): DailyDataPoint[] => [
  {
    day: '2026-04-01',
    dailyIncome: 100 + offset,
    dailyExpense: 50 + offset,
    runningBalance: 500 + offset,
  },
  {
    day: '2026-04-02',
    dailyIncome: 200 + offset,
    dailyExpense: 80 + offset,
    runningBalance: 620 + offset,
  },
];

describe('FinancialMonthlyOverviewCard', () => {
  let component: FinancialMonthlyOverviewCard;
  let fixture: ComponentFixture<FinancialMonthlyOverviewCard>;

  const dailyOverview = signal<DailyDataPoint[]>([]);
  const previousDailyOverview = signal<DailyDataPoint[]>([]);
  const isDailyOverviewLoading = signal(false);

  const mockStore = {
    dailyOverview,
    previousDailyOverview,
    isDailyOverviewLoading,
  };

  beforeEach(async () => {
    dailyOverview.set([]);
    previousDailyOverview.set([]);
    isDailyOverviewLoading.set(false);

    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    await TestBed.configureTestingModule({
      imports: [FinancialMonthlyOverviewCard],
      providers: [{ provide: AnalyticsStore, useValue: mockStore }],
    }).compileComponents();

    fixture = TestBed.createComponent(FinancialMonthlyOverviewCard);
    component = fixture.componentInstance;
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('labels returns day strings from dailyOverview', () => {
    dailyOverview.set(makeDataPoints());
    expect(component['labels']()).toEqual(['2026-04-01', '2026-04-02']);
  });

  it('currentAmounts maps runningBalance for Total balance type (default)', () => {
    dailyOverview.set(makeDataPoints());
    expect(component['currentAmounts']()).toEqual([500, 620]);
  });

  it('currentAmounts maps dailyIncome for Total income type', () => {
    dailyOverview.set(makeDataPoints());
    component['type'].set({ name: 'Total income' });
    expect(component['currentAmounts']()).toEqual([100, 200]);
  });

  it('currentAmounts maps dailyExpense for Total expenses type', () => {
    dailyOverview.set(makeDataPoints());
    component['type'].set({ name: 'Total expenses' });
    expect(component['currentAmounts']()).toEqual([50, 80]);
  });

  it('previousAmounts maps runningBalance for Total balance type (default)', () => {
    previousDailyOverview.set(makeDataPoints(10));
    expect(component['previousAmounts']()).toEqual([510, 630]);
  });

  it('previousAmounts maps dailyIncome for Total income type', () => {
    previousDailyOverview.set(makeDataPoints(10));
    component['type'].set({ name: 'Total income' });
    expect(component['previousAmounts']()).toEqual([110, 210]);
  });

  it('previousAmounts maps dailyExpense for Total expenses type', () => {
    previousDailyOverview.set(makeDataPoints(10));
    component['type'].set({ name: 'Total expenses' });
    expect(component['previousAmounts']()).toEqual([60, 90]);
  });

  it('shows skeleton when isDailyOverviewLoading is true', async () => {
    isDailyOverviewLoading.set(true);
    fixture.detectChanges();
    await fixture.whenStable();

    const skeleton = fixture.nativeElement.querySelector('p-skeleton');
    const chart = fixture.nativeElement.querySelector(
      'app-financial-monthly-overview-chart',
    );
    expect(skeleton).toBeTruthy();
    expect(chart).toBeFalsy();
  });

  it('shows chart when isDailyOverviewLoading is false', async () => {
    isDailyOverviewLoading.set(false);
    fixture.detectChanges();
    await fixture.whenStable();

    const skeleton = fixture.nativeElement.querySelector('p-skeleton');
    const chart = fixture.nativeElement.querySelector(
      'app-financial-monthly-overview-chart',
    );
    expect(skeleton).toBeFalsy();
    expect(chart).toBeTruthy();
  });
});
