import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AccountCard } from './account-card';

describe('AccountCard', () => {
  let component: AccountCard;
  let fixture: ComponentFixture<AccountCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AccountCard],
    }).compileComponents();

    fixture = TestBed.createComponent(AccountCard);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('currency', 'USD');
    fixture.componentRef.setInput('name', 'Some account name');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
