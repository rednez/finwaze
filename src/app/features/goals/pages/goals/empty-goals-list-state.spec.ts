import { ComponentFixture, TestBed } from '@angular/core/testing';
import { EmptyGoalsListState } from './empty-goals-list-state';

describe('EmptyGoalsListState', () => {
  let component: EmptyGoalsListState;
  let fixture: ComponentFixture<EmptyGoalsListState>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EmptyGoalsListState],
    }).compileComponents();

    fixture = TestBed.createComponent(EmptyGoalsListState);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
