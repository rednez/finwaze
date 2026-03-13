import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CardFailedState } from './card-failed-state';

describe('CardFailedState', () => {
  let component: CardFailedState;
  let fixture: ComponentFixture<CardFailedState>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CardFailedState]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CardFailedState);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
