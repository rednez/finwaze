import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { NewAccount } from './new-account';

describe('NewAccount', () => {
  let component: NewAccount;
  let fixture: ComponentFixture<NewAccount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NewAccount],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(NewAccount);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
