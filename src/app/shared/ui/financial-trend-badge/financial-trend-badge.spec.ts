import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { FinancialTrendBadge } from './financial-trend-badge';

describe('FinancialTrendBadge', () => {
  let fixture: ComponentFixture<FinancialTrendBadge>;
  let component: FinancialTrendBadge;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FinancialTrendBadge],
    }).compileComponents();

    fixture = TestBed.createComponent(FinancialTrendBadge);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  const setInputs = (
    currentAmount: number,
    previousAmount: number,
    growTrendIsGood: boolean,
  ) => {
    fixture.componentRef.setInput('currentAmount', currentAmount);
    fixture.componentRef.setInput('previousAmount', previousAmount);
    fixture.componentRef.setInput('growTrendIsGood', growTrendIsGood);
    fixture.detectChanges();
  };

  const getBadgeClasses = () => {
    const badge = fixture.debugElement.query(By.css('div'));
    return badge.nativeElement.classList as DOMTokenList;
  };

  it('marks positive delta as good when growTrendIsGood is true', () => {
    setInputs(110, 100, true);

    const classes = getBadgeClasses();

    expect(classes.contains('text-green-600')).toBe(true);
    expect(classes.contains('bg-green-100')).toBe(true);
    expect(classes.contains('text-red-600')).toBe(false);
    expect(classes.contains('bg-red-100')).toBe(false);
    expect(classes.contains('text-gray-600')).toBe(false);
    expect(classes.contains('bg-gray-100')).toBe(false);
  });

  it('marks positive delta as bad when growTrendIsGood is false', () => {
    setInputs(110, 100, false);

    const classes = getBadgeClasses();

    expect(classes.contains('text-red-600')).toBe(true);
    expect(classes.contains('bg-red-100')).toBe(true);
    expect(classes.contains('text-green-600')).toBe(false);
    expect(classes.contains('bg-green-100')).toBe(false);
    expect(classes.contains('text-gray-600')).toBe(false);
    expect(classes.contains('bg-gray-100')).toBe(false);
  });

  it('marks zero delta as neutral', () => {
    setInputs(100, 100, true);

    const classes = getBadgeClasses();

    expect(classes.contains('text-gray-600')).toBe(true);
    expect(classes.contains('bg-gray-100')).toBe(true);
    expect(classes.contains('text-green-600')).toBe(false);
    expect(classes.contains('bg-green-100')).toBe(false);
    expect(classes.contains('text-red-600')).toBe(false);
    expect(classes.contains('bg-red-100')).toBe(false);
  });
});
