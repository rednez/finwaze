import { ComponentFixture, TestBed } from '@angular/core/testing';
import { LOCALE_ID } from '@angular/core';
import { StyledAmount } from './styled-amount';

describe('StyledAmount', () => {
  let component: StyledAmount;
  let fixture: ComponentFixture<StyledAmount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StyledAmount],
      providers: [{ provide: LOCALE_ID, useValue: 'en-US' }],
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

  it('should format currency with decimal part separated', () => {
    expect(component.mainPart()).toBe('$1,234');
    expect(component.decimalPart()).toBe('.56');
  });

  it('should handle whole numbers', () => {
    fixture.componentRef.setInput('amount', 1000);
    fixture.detectChanges();

    expect(component.mainPart()).toBe('$1,000');
    expect(component.decimalPart()).toBe('.00');
  });

  it('should render decimal part with correct styling', () => {
    fixture.detectChanges();
    const decimalSpan = fixture.nativeElement.querySelectorAll('span')[1];
    expect(decimalSpan.textContent).toBe('.56');
    expect(decimalSpan.classList.contains('text-gray-300')).toBe(true);
  });
});
