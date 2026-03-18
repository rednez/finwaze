import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WalletRecentTransactionsCard } from './wallet-recent-transactions-card';

describe('WalletRecentTransactionsCard', () => {
  let component: WalletRecentTransactionsCard;
  let fixture: ComponentFixture<WalletRecentTransactionsCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WalletRecentTransactionsCard],
    }).compileComponents();

    fixture = TestBed.createComponent(WalletRecentTransactionsCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
