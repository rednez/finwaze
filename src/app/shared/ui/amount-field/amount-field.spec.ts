import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AmountField } from './amount-field';

describe('AmountField', () => {
  let component: AmountField;
  let fixture: ComponentFixture<AmountField>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AmountField],
    }).compileComponents();

    fixture = TestBed.createComponent(AmountField);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('inputId', 'test-amount');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
