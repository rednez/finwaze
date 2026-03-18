import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransferDetails } from './transfer-details';

describe('TransferDetails', () => {
  let component: TransferDetails;
  let fixture: ComponentFixture<TransferDetails>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransferDetails],
    }).compileComponents();

    fixture = TestBed.createComponent(TransferDetails);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
