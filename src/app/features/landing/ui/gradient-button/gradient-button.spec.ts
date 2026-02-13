import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GradientButton } from './gradient-button';

describe('GradientButton', () => {
  let component: GradientButton;
  let fixture: ComponentFixture<GradientButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GradientButton]
    })
    .compileComponents();

    fixture = TestBed.createComponent(GradientButton);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
