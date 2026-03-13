import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DescriptionSection } from './description-section';

describe('DescriptionSection', () => {
  let component: DescriptionSection;
  let fixture: ComponentFixture<DescriptionSection>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DescriptionSection],
    }).compileComponents();

    fixture = TestBed.createComponent(DescriptionSection);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
