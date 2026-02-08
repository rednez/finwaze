import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FinancialMonthlyOverviewChart } from './financial-monthly-overview-chart';

describe('FinancialMonthlyOverviewChart', () => {
  let component: FinancialMonthlyOverviewChart;
  let fixture: ComponentFixture<FinancialMonthlyOverviewChart>;

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
      imports: [FinancialMonthlyOverviewChart],
    }).compileComponents();

    fixture = TestBed.createComponent(FinancialMonthlyOverviewChart);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
