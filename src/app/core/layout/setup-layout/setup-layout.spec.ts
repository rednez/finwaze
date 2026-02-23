import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SetupLayout } from './setup-layout';

describe('SetupLayout', () => {
  let component: SetupLayout;
  let fixture: ComponentFixture<SetupLayout>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SetupLayout]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SetupLayout);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
