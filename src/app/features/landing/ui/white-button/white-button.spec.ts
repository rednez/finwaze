import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WhiteButton } from './white-button';

describe('WhiteButton', () => {
  let component: WhiteButton;
  let fixture: ComponentFixture<WhiteButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WhiteButton]
    })
    .compileComponents();

    fixture = TestBed.createComponent(WhiteButton);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
