import { provideRouter } from '@angular/router';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SigninWithEmail } from './signin-with-email';

describe('Signin', () => {
  let component: SigninWithEmail;
  let fixture: ComponentFixture<SigninWithEmail>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SigninWithEmail],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(SigninWithEmail);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
