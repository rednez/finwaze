import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { CategoriesStore } from '@core/store/categories-store';
import { BudgetStore } from '../../stores';
import { BudgetRepository } from '../../repositories';
import { CreateBudget } from './create-budget';

function makeBudgetStoreMock(currencyCode: string | null = 'USD') {
  return {
    provide: BudgetStore,
    useValue: {
      month: () => new Date('2026-03-01'),
      currencyCode: () => currencyCode,
    },
  };
}

function makeCategoriesStoreMock() {
  return {
    provide: CategoriesStore,
    useValue: {
      isLoaded: () => true,
      loadAll: vi.fn(),
    },
  };
}

function makeRepositoryMock() {
  return {
    provide: BudgetRepository,
    useValue: {
      getDetailedMonthlyBudgets: vi.fn().mockResolvedValue([]),
      upsertMonthlyBudgets: vi.fn().mockResolvedValue(undefined),
    },
  };
}

describe('CreateBudget', () => {
  describe('with currencyCode set', () => {
    let component: CreateBudget;
    let fixture: ComponentFixture<CreateBudget>;

    beforeEach(async () => {
      await TestBed.configureTestingModule({
        imports: [CreateBudget],
        providers: [
          provideRouter([]),
          makeBudgetStoreMock('USD'),
          makeCategoriesStoreMock(),
          makeRepositoryMock(),
        ],
      }).compileComponents();

      fixture = TestBed.createComponent(CreateBudget);
      component = fixture.componentInstance;
      await fixture.whenStable();
    });

    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('calls loadExistingBudget on init', () => {
      const repository = TestBed.inject(BudgetRepository);
      expect(repository.getDetailedMonthlyBudgets).toHaveBeenCalledWith({
        month: '2026-03-01',
        currencyCode: 'USD',
      });
    });
  });

  describe('with currencyCode null', () => {
    beforeEach(async () => {
      await TestBed.configureTestingModule({
        imports: [CreateBudget],
        providers: [
          provideRouter([]),
          makeBudgetStoreMock(null),
          makeCategoriesStoreMock(),
          makeRepositoryMock(),
        ],
      }).compileComponents();

      const f = TestBed.createComponent(CreateBudget);
      await f.whenStable();
    });

    it('does not call loadExistingBudget on init', () => {
      const repository = TestBed.inject(BudgetRepository);
      expect(repository.getDetailedMonthlyBudgets).not.toHaveBeenCalled();
    });
  });
});
