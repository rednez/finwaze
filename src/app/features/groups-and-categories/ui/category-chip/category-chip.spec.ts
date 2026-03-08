import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CategoryChip } from './category-chip';

describe('CategoryChip', () => {
  let component: CategoryChip;
  let fixture: ComponentFixture<CategoryChip>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CategoryChip],
    }).compileComponents();

    fixture = TestBed.createComponent(CategoryChip);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
