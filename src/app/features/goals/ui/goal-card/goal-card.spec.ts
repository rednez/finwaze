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
  hasTransfers: false,
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
      expect(component['canWithdraw']()).toBe(false);
    });

    it('is visible when accumulatedAmount > 0 and status is inProgress', () => {
      setGoal({ accumulatedAmount: 300, status: 'inProgress' });
      expect(component['canWithdraw']()).toBe(true);
    });

    it('is visible when accumulatedAmount > 0 and status is notStarted', () => {
      setGoal({ accumulatedAmount: 50, status: 'notStarted' });
      expect(component['canWithdraw']()).toBe(true);
    });

    it('is hidden when status is done', () => {
      setGoal({ accumulatedAmount: 1500, status: 'done' });
      expect(component['canWithdraw']()).toBe(false);
    });

    it('is hidden when status is cancelled', () => {
      setGoal({ accumulatedAmount: 500, status: 'cancelled' });
      expect(component['canWithdraw']()).toBe(false);
    });

    it('emits withdrawClicked with the goal when clicked', () => {
      setGoal({ accumulatedAmount: 300, status: 'inProgress' });

      let emitted: SavingsGoal | undefined;
      fixture.componentInstance.withdrawClicked.subscribe(
        (g: SavingsGoal) => (emitted = g),
      );

      component['withdraw'](new MouseEvent('click'));
      fixture.detectChanges();

      expect(emitted).toEqual({ ...baseGoal, accumulatedAmount: 300 });
    });
  });
});
