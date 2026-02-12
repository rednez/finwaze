import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CardHeaderTitle } from './card-header-title';

describe('CardHeaderTitle', () => {
  let component: CardHeaderTitle;
  let fixture: ComponentFixture<CardHeaderTitle>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CardHeaderTitle]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CardHeaderTitle);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
