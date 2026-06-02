import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SetupAccount } from './setup-account';
import { MessageService } from 'primeng/api';

describe('SetupAccount', () => {
  let component: SetupAccount;
  let fixture: ComponentFixture<SetupAccount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SetupAccount],
      providers: [MessageService],
    }).compileComponents();

    fixture = TestBed.createComponent(SetupAccount);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
