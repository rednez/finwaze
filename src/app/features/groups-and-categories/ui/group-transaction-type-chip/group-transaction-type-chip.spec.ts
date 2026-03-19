import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupTransactionTypeChip } from './group-transaction-type-chip';

describe('GroupTransactionTypeChip', () => {
  let component: GroupTransactionTypeChip;
  let fixture: ComponentFixture<GroupTransactionTypeChip>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GroupTransactionTypeChip],
    }).compileComponents();

    fixture = TestBed.createComponent(GroupTransactionTypeChip);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
