import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TotalBudget } from './total-budget';

describe('TotalBudget', () => {
  let component: TotalBudget;
  let fixture: ComponentFixture<TotalBudget>;

  beforeEach(async () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    await TestBed.configureTestingModule({
      imports: [TotalBudget],
    }).compileComponents();

    fixture = TestBed.createComponent(TotalBudget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
