import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FormPageLayout } from './form-page-layout';

describe('FormPageLayout', () => {
  let component: FormPageLayout;
  let fixture: ComponentFixture<FormPageLayout>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FormPageLayout],
    }).compileComponents();

    fixture = TestBed.createComponent(FormPageLayout);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
