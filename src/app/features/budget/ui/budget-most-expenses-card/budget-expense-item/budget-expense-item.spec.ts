import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetExpenseItem } from './budget-expense-item';

describe('BudgetExpenseItem', () => {
  let component: BudgetExpenseItem;
  let fixture: ComponentFixture<BudgetExpenseItem>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetExpenseItem],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetExpenseItem);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('name', 'Food');
    fixture.componentRef.setInput('currentAmount', 1200.4);
    fixture.componentRef.setInput('previousPeriodAmount', 1000);
    fixture.componentRef.setInput('currency', 'USD');
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
