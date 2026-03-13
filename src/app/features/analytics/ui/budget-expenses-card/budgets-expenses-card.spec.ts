import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetsExpensesCard } from './budgets-expenses-card';

describe('BudgetsExpensesCard', () => {
  let component: BudgetsExpensesCard;
  let fixture: ComponentFixture<BudgetsExpensesCard>;

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
      imports: [BudgetsExpensesCard],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetsExpensesCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
