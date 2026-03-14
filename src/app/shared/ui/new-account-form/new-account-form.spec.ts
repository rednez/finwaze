import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NewAccountForm } from './new-account-form';

describe('NewAccountForm', () => {
  let component: NewAccountForm;
  let fixture: ComponentFixture<NewAccountForm>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NewAccountForm],
    }).compileComponents();

    fixture = TestBed.createComponent(NewAccountForm);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
