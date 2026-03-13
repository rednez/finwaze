import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TransactionsDataTable } from './transactions-data-table';

describe('TransactionsDataTable', () => {
  let component: TransactionsDataTable;
  let fixture: ComponentFixture<TransactionsDataTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransactionsDataTable],
    }).compileComponents();

    fixture = TestBed.createComponent(TransactionsDataTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
