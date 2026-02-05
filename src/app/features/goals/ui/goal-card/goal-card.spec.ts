import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GoalCard } from './goal-card';

describe('GoalCard', () => {
  let component: GoalCard;
  let fixture: ComponentFixture<GoalCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GoalCard],
    }).compileComponents();

    fixture = TestBed.createComponent(GoalCard);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('goal', {
      id: 1,
      name: 'Buy a new laptop',
      targetAmount: 1500,
      savingAmount: 300,
      dueDate: new Date('2026-12-30'),
      currency: 'USD',
    });

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
