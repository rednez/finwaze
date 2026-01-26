import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SavingGoalsWidget } from './saving-goals-widget';

describe('SavingGoalsWidget', () => {
  let component: SavingGoalsWidget;
  let fixture: ComponentFixture<SavingGoalsWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SavingGoalsWidget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SavingGoalsWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
