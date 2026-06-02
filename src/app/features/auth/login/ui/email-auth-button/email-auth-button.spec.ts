import { ComponentFixture, TestBed } from '@angular/core/testing';
import { EmailAuthButton } from './email-auth-button';

describe('EmailAuthButton', () => {
  let component: EmailAuthButton;
  let fixture: ComponentFixture<EmailAuthButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EmailAuthButton],
    }).compileComponents();

    fixture = TestBed.createComponent(EmailAuthButton);
    fixture.componentRef.setInput('label', 'Sign up');
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
