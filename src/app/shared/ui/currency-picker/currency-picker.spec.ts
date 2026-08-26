import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CurrencyPicker } from './currency-picker';

describe('CurrencyPicker', () => {
  let component: CurrencyPicker;
  let fixture: ComponentFixture<CurrencyPicker>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CurrencyPicker],
    }).compileComponents();

    fixture = TestBed.createComponent(CurrencyPicker);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
