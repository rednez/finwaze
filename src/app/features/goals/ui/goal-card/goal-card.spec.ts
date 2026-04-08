import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { GoalCard } from './goal-card';

const baseGoal: SavingsGoal = {
  id: 1,
  name: 'Buy a new laptop',
  targetAmount: 1500,
  accumulatedAmount: 0,
  targetDate: new Date('2026-12-30'),
  currencyCode: 'USD',
  status: 'inProgress',
};

describe('GoalCard', () => {
  let component: GoalCard;
  let fixture: ComponentFixture<GoalCard>;

  function setGoal(overrides: Partial<SavingsGoal> = {}) {
    fixture.componentRef.setInput('goal', { ...baseGoal, ...overrides });
    fixture.detectChanges();
  }

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GoalCard],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(GoalCard);
    component = fixture.componentInstance;
    setGoal();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('Withdraw button', () => {
    it('is hidden when accumulatedAmount is 0', () => {
      setGoal({ accumulatedAmount: 0, status: 'inProgress' });
      const btn = fixture.nativeElement.querySelector(
        'p-button[label="Withdraw"]',
      );
      expect(btn).toBeNull();
    });

    it('is visible when accumulatedAmount > 0 and status is inProgress', () => {
      setGoal({ accumulatedAmount: 300, status: 'inProgress' });
      const btn = fixture.nativeElement.querySelector(
        'p-button[label="Withdraw"]',
      );
      expect(btn).not.toBeNull();
    });

    it('is visible when accumulatedAmount > 0 and status is notStarted', () => {
      setGoal({ accumulatedAmount: 50, status: 'notStarted' });
      const btn = fixture.nativeElement.querySelector(
        'p-button[label="Withdraw"]',
      );
      expect(btn).not.toBeNull();
    });

    it('emits withdrawClicked with the goal when clicked', () => {
      setGoal({ accumulatedAmount: 300, status: 'inProgress' });

      let emitted: SavingsGoal | undefined;
      fixture.componentInstance.withdrawClicked.subscribe(
        (g: SavingsGoal) => (emitted = g),
      );

      const btn = fixture.nativeElement.querySelector(
        'p-button[label="Withdraw"]',
      );
      btn.dispatchEvent(new CustomEvent('onClick', { bubbles: true }));
      fixture.detectChanges();

      expect(emitted).toEqual({ ...baseGoal, accumulatedAmount: 300 });
    });
  });
});
