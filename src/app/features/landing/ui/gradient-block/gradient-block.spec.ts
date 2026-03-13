import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GradientBlock } from './gradient-block';

describe('GradientBlock', () => {
  let component: GradientBlock;
  let fixture: ComponentFixture<GradientBlock>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GradientBlock]
    })
    .compileComponents();

    fixture = TestBed.createComponent(GradientBlock);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
