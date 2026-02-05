import { ComponentFixture, TestBed } from '@angular/core/testing';
import { GoalsFilters } from './goals-filters';

describe('GoalsFilters', () => {
  let component: GoalsFilters;
  let fixture: ComponentFixture<GoalsFilters>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GoalsFilters],
    }).compileComponents();

    fixture = TestBed.createComponent(GoalsFilters);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
