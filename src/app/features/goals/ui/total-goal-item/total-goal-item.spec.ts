import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TotalGoalItem } from './total-goal-item';

describe('TotalGoalItem', () => {
  let component: TotalGoalItem;
  let fixture: ComponentFixture<TotalGoalItem>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TotalGoalItem],
    }).compileComponents();

    fixture = TestBed.createComponent(TotalGoalItem);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
