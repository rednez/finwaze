import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetsExpensesChart } from './budgets-expenses-chart';

describe('BudgetsExpensesChart', () => {
  let component: BudgetsExpensesChart;
  let fixture: ComponentFixture<BudgetsExpensesChart>;

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
      imports: [BudgetsExpensesChart],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetsExpensesChart);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
