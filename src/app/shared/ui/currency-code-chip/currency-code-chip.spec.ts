import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CurrencyCodeChip } from './currency-code-chip';

describe('CurrencyCodeChip', () => {
  let component: CurrencyCodeChip;
  let fixture: ComponentFixture<CurrencyCodeChip>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CurrencyCodeChip],
    }).compileComponents();

    fixture = TestBed.createComponent(CurrencyCodeChip);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
