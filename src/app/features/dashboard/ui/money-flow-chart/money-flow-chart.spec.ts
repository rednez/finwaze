import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MoneyFlowChart } from './money-flow-chart';

describe('MoneyFlowChart', () => {
  let component: MoneyFlowChart;
  let fixture: ComponentFixture<MoneyFlowChart>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MoneyFlowChart],
    }).compileComponents();

    fixture = TestBed.createComponent(MoneyFlowChart);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('labels', []);
    fixture.componentRef.setInput('incomes', []);
    fixture.componentRef.setInput('expenses', []);

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
