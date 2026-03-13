import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetCardSummary } from './budget-card-summary';

describe('BudgetCardSummary', () => {
  let component: BudgetCardSummary;
  let fixture: ComponentFixture<BudgetCardSummary>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetCardSummary],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetCardSummary);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'USD');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
