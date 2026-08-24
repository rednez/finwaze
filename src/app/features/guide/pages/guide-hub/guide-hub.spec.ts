import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { GuideHub } from './guide-hub';

describe('GuideHub', () => {
  let component: GuideHub;
  let fixture: ComponentFixture<GuideHub>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideHub],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideHub);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
