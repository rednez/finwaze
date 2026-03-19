import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransactionTypeChip } from './transaction-type-chip';

describe('TransactionTypeChip', () => {
  let component: TransactionTypeChip;
  let fixture: ComponentFixture<TransactionTypeChip>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransactionTypeChip],
    }).compileComponents();

    fixture = TestBed.createComponent(TransactionTypeChip);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
