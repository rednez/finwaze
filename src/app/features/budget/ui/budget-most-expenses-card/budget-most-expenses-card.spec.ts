import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetMostExpensesCard } from './budget-most-expenses-card';

describe('BudgetMostExpensesCard', () => {
  let component: BudgetMostExpensesCard;
  let fixture: ComponentFixture<BudgetMostExpensesCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetMostExpensesCard]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BudgetMostExpensesCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
