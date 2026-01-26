import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RecentTransactionsWidget } from './recent-transactions-widget';

describe('RecentTransactionsWidget', () => {
  let component: RecentTransactionsWidget;
  let fixture: ComponentFixture<RecentTransactionsWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RecentTransactionsWidget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RecentTransactionsWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
