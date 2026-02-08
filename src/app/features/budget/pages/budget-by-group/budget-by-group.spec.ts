import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetByGroup } from './budget-by-group';

describe('BudgetByGroup', () => {
  let component: BudgetByGroup;
  let fixture: ComponentFixture<BudgetByGroup>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetByGroup],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetByGroup);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('categories', []);
    fixture.componentRef.setInput('mostExpenses', []);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
