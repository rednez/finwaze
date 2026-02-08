import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FinancialMonthlyOverviewCard } from './financial-monthly-overview-card';

describe('FinancialMonthlyOverviewCard', () => {
  let component: FinancialMonthlyOverviewCard;
  let fixture: ComponentFixture<FinancialMonthlyOverviewCard>;

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
      imports: [FinancialMonthlyOverviewCard],
    }).compileComponents();

    fixture = TestBed.createComponent(FinancialMonthlyOverviewCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
