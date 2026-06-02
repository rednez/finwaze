import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { AccountSettings } from './account-settings';
import { MessageService } from 'primeng/api';

describe('AccountSettings', () => {
  let component: AccountSettings;
  let fixture: ComponentFixture<AccountSettings>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AccountSettings],
      providers: [MessageService, provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(AccountSettings);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
