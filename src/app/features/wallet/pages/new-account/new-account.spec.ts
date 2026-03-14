import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NewAccount } from './new-account';

describe('NewAccount', () => {
  let component: NewAccount;
  let fixture: ComponentFixture<NewAccount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NewAccount],
    }).compileComponents();

    fixture = TestBed.createComponent(NewAccount);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
