import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Account } from '@core/models/accounts';
import { SavingsGoal } from '@core/models/savings-goal';
import { CompleteGoalDialog } from './complete-goal-dialog';

const goal: SavingsGoal = {
  id: 5,
  name: 'Dream Vacation',
  targetAmount: 3000,
  accumulatedAmount: 3000,
  targetDate: new Date('2026-12-01'),
  currencyCode: 'USD',
  status: 'inProgress',
  hasTransfers: true,
};

const accounts: Account[] = [
  { id: 1, name: 'Checking USD', currencyCode: 'USD' },
  { id: 2, name: 'Cash USD', currencyCode: 'USD' },
];

describe('CompleteGoalDialog', () => {
  let component: CompleteGoalDialog;
  let fixture: ComponentFixture<CompleteGoalDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompleteGoalDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(CompleteGoalDialog);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('goal', goal);
    fixture.componentRef.setInput('accounts', accounts);
    fixture.componentRef.setInput('visible', true);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('confirm', () => {
    it('does not emit when toAccountId is empty', () => {
      let emitted = false;
      component.confirmed.subscribe(() => (emitted = true));

      component['confirm']();

      expect(emitted).toBe(false);
    });

    it('marks form as touched on invalid submit', () => {
      component['confirm']();

      expect(component['form'].controls.toAccountId.touched).toBe(true);
    });

    it('emits confirmed with toAccountId on valid submit', () => {
      let payload: { toAccountId: number } | undefined;
      component.confirmed.subscribe((p) => (payload = p));

      component['form'].patchValue({ toAccountId: 1 });
      component['confirm']();

      expect(payload).toEqual({ toAccountId: 1 });
    });
  });

  describe('close', () => {
    it('sets visible to false', () => {
      component['close']();

      expect(component.visible()).toBe(false);
    });
  });
});
