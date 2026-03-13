import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FormActionButtons } from './form-action-buttons';

describe('FormActionButtons', () => {
  let component: FormActionButtons;
  let fixture: ComponentFixture<FormActionButtons>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FormActionButtons],
    }).compileComponents();

    fixture = TestBed.createComponent(FormActionButtons);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
