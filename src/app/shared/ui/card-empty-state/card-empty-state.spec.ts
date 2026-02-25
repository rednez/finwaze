import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CardEmptyState } from './card-empty-state';

describe('CardEmptyState', () => {
  let component: CardEmptyState;
  let fixture: ComponentFixture<CardEmptyState>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CardEmptyState]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CardEmptyState);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
