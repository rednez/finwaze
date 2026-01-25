import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MoneyFlowWidget } from './money-flow-widget';

describe('MoneyFlowWidget', () => {
  let component: MoneyFlowWidget;
  let fixture: ComponentFixture<MoneyFlowWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MoneyFlowWidget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MoneyFlowWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
