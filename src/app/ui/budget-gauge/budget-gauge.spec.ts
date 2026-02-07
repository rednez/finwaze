import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ComponentRef } from '@angular/core';

import { BudgetGauge } from './budget-gauge';

describe('BudgetGauge', () => {
  let component: BudgetGauge;
  let componentRef: ComponentRef<BudgetGauge>;
  let fixture: ComponentFixture<BudgetGauge>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetGauge],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetGauge);
    component = fixture.componentInstance;
    componentRef = fixture.componentRef;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
