import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PasskeyButton } from './passkey-button';

describe('PasskeyButton', () => {
  let component: PasskeyButton;
  let fixture: ComponentFixture<PasskeyButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PasskeyButton],
    }).compileComponents();

    fixture = TestBed.createComponent(PasskeyButton);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
