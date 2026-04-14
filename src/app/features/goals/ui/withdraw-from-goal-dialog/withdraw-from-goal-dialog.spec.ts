import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Account } from '@core/models/accounts';
import { SavingsGoal } from '@core/models/savings-goal';
import { WithdrawFromGoalDialog } from './withdraw-from-goal-dialog';

const goal: SavingsGoal = {
  id: 10,
  name: 'New Car',
  targetAmount: 5000,
  accumulatedAmount: 1000,
  targetDate: new Date('2027-06-01'),
  currencyCode: 'USD',
  status: 'inProgress',
  hasTransfers: true,
};

const accounts: Account[] = [
  { id: 1, name: 'Checking USD', currencyCode: 'USD' },
  { id: 2, name: 'Savings EUR', currencyCode: 'EUR' },
  { id: 3, name: 'Cash USD', currencyCode: 'USD' },
  { id: 10, name: 'New Car (goal)', currencyCode: 'USD' }, // same id as goal — must be excluded
];

describe('WithdrawFromGoalDialog', () => {
  let component: WithdrawFromGoalDialog;
  let fixture: ComponentFixture<WithdrawFromGoalDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WithdrawFromGoalDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(WithdrawFromGoalDialog);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('goal', goal);
    fixture.componentRef.setInput('accounts', accounts);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('filteredAccounts', () => {
    it('includes only accounts with matching currency', () => {
      const ids = component['filteredAccounts']().map((a: Account) => a.id);
      expect(ids).not.toContain(2); // EUR account excluded
    });

    it('excludes the goal account itself', () => {
      const ids = component['filteredAccounts']().map((a: Account) => a.id);
      expect(ids).not.toContain(10); // goal id excluded
    });

    it('includes USD accounts that are not the goal', () => {
      const ids = component['filteredAccounts']().map((a: Account) => a.id);
      expect(ids).toContain(1);
      expect(ids).toContain(3);
    });
  });

  describe('form validation', () => {
    it('is invalid when toAccountId and amount are empty', () => {
      expect(component['form'].invalid).toBe(true);
    });

    it('is invalid when amount is 0', () => {
      component['form'].patchValue({ toAccountId: 1, amount: 0 });
      expect(component['form'].invalid).toBe(true);
    });

    it('is valid when toAccountId and amount > 0 are set', () => {
      component['form'].patchValue({ toAccountId: 1, amount: 200 });
      expect(component['form'].valid).toBe(true);
    });

    it('is invalid when amount exceeds accumulatedAmount', () => {
      component['form'].patchValue({ toAccountId: 1, amount: 1001 });
      expect(component['form'].controls.amount.hasError('max')).toBe(true);
    });

    it('is valid when amount equals accumulatedAmount', () => {
      component['form'].patchValue({ toAccountId: 1, amount: 1000 });
      expect(component['form'].valid).toBe(true);
    });
  });

  describe('submit', () => {
    it('does not emit when form is invalid', () => {
      let emitted = false;
      component.submitted.subscribe(() => (emitted = true));

      component['submit']();

      expect(emitted).toBe(false);
    });

    it('emits submitted event with correct payload on valid submit', () => {
      let payload:
        | { toAccountId: number; amount: number; transactedAt?: Date | null }
        | undefined;
      component.submitted.subscribe((p) => (payload = p));

      component['form'].patchValue({ toAccountId: 1, amount: 200, transactedAt: null });

      component['submit']();

      expect(payload).toEqual({ toAccountId: 1, amount: 200, transactedAt: null });
    });
  });
});
