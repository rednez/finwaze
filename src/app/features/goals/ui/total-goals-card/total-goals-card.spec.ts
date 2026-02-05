import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TotalGoalsCard } from './total-goals-card';

describe('TotalGoalsCard', () => {
  let component: TotalGoalsCard;
  let fixture: ComponentFixture<TotalGoalsCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TotalGoalsCard]
    })
    .compileComponents();

    fixture = TestBed.createComponent(TotalGoalsCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
