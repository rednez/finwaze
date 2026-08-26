import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ResponsiveOverlay } from './responsive-overlay';

describe('ResponsiveOverlay', () => {
  let component: ResponsiveOverlay;
  let fixture: ComponentFixture<ResponsiveOverlay>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResponsiveOverlay],
    }).compileComponents();

    fixture = TestBed.createComponent(ResponsiveOverlay);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
