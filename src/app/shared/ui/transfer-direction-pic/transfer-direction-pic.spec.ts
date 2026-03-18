import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransferDirectionPic } from './transfer-direction-pic';

describe('TransferDirectionPic', () => {
  let component: TransferDirectionPic;
  let fixture: ComponentFixture<TransferDirectionPic>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TransferDirectionPic],
    }).compileComponents();

    fixture = TestBed.createComponent(TransferDirectionPic);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
