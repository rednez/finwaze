import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ExchangeRateChip } from './exchange-rate-chip';

describe('ExchangeRateChip', () => {
  let component: ExchangeRateChip;
  let fixture: ComponentFixture<ExchangeRateChip>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ExchangeRateChip],
    }).compileComponents();

    fixture = TestBed.createComponent(ExchangeRateChip);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
