import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TransactionsFilters } from './transactions-filters';

describe('TransactionsFilters', () => {
  let component: TransactionsFilters;
  let fixture: ComponentFixture<TransactionsFilters>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransactionsFilters],
    }).compileComponents();

    fixture = TestBed.createComponent(TransactionsFilters);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
