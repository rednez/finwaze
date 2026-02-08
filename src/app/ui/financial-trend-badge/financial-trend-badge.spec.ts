import { Component } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { FinancialTrendBadge } from './financial-trend-badge';

@Component({
  template: `
    <app-financial-trend-badge
      [currentAmount]="currentAmount"
      [previousAmount]="previousAmount"
      [growTrendIsGood]="growTrendIsGood"
    />
  `,
  imports: [FinancialTrendBadge],
})
class TestHostComponent {
  currentAmount = 0;
  previousAmount = 0;
  growTrendIsGood = false;
}

describe('FinancialTrendBadge', () => {
  let host: TestHostComponent;
  let fixture: ComponentFixture<TestHostComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TestHostComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(TestHostComponent);
    host = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(host).toBeTruthy();
  });

  const getBadgeClasses = () => {
    const badge = fixture.debugElement.query(
      By.css('app-financial-trend-badge div'),
    );
    return badge.nativeElement.classList as DOMTokenList;
  };

  it('marks positive delta as good when growTrendIsGood is true', () => {
    host.growTrendIsGood = true;
    host.previousAmount = 100;
    host.currentAmount = 110;
    fixture.detectChanges();

    const classes = getBadgeClasses();

    expect(classes.contains('text-green-600')).toBe(true);
    expect(classes.contains('bg-green-100')).toBe(true);
    expect(classes.contains('text-red-600')).toBe(false);
    expect(classes.contains('bg-red-100')).toBe(false);
    expect(classes.contains('text-gray-600')).toBe(false);
    expect(classes.contains('bg-gray-100')).toBe(false);
  });

  it('marks positive delta as bad when growTrendIsGood is false', () => {
    host.growTrendIsGood = false;
    host.previousAmount = 100;
    host.currentAmount = 110;
    fixture.detectChanges();

    const classes = getBadgeClasses();

    expect(classes.contains('text-red-600')).toBe(true);
    expect(classes.contains('bg-red-100')).toBe(true);
    expect(classes.contains('text-green-600')).toBe(false);
    expect(classes.contains('bg-green-100')).toBe(false);
    expect(classes.contains('text-gray-600')).toBe(false);
    expect(classes.contains('bg-gray-100')).toBe(false);
  });

  it('marks zero delta as neutral', () => {
    host.growTrendIsGood = true;
    host.previousAmount = 100;
    host.currentAmount = 100;
    fixture.detectChanges();

    const classes = getBadgeClasses();

    expect(classes.contains('text-gray-600')).toBe(true);
    expect(classes.contains('bg-gray-100')).toBe(true);
    expect(classes.contains('text-green-600')).toBe(false);
    expect(classes.contains('bg-green-100')).toBe(false);
    expect(classes.contains('text-red-600')).toBe(false);
    expect(classes.contains('bg-red-100')).toBe(false);
  });
});
