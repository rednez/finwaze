import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GoalCardStatus } from './goal-card-status';

describe('GoalCardStatus', () => {
  let component: GoalCardStatus;
  let fixture: ComponentFixture<GoalCardStatus>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GoalCardStatus]
    })
    .compileComponents();

    fixture = TestBed.createComponent(GoalCardStatus);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
