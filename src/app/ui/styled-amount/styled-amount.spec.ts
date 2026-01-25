import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StyledAmount } from './styled-amount';

describe('StyledAmount', () => {
  let component: StyledAmount;
  let fixture: ComponentFixture<StyledAmount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StyledAmount],
    }).compileComponents();

    fixture = TestBed.createComponent(StyledAmount);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('currency', 'USD');
    fixture.componentRef.setInput('amount', 1234.56);

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
