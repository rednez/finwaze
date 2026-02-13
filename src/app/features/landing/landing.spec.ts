import { ComponentFixture, TestBed } from '@angular/core/testing';

import { OnBoarding } from './landing';

describe('OnBoarding', () => {
  let component: OnBoarding;
  let fixture: ComponentFixture<OnBoarding>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OnBoarding],
    }).compileComponents();

    fixture = TestBed.createComponent(OnBoarding);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
