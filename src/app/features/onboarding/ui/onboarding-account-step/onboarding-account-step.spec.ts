import { ComponentFixture, TestBed } from '@angular/core/testing';
import { OnboardingAccountStep } from './onboarding-account-step';

describe('OnboardingAccountStep', () => {
  let component: OnboardingAccountStep;
  let fixture: ComponentFixture<OnboardingAccountStep>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OnboardingAccountStep],
    }).compileComponents();

    fixture = TestBed.createComponent(OnboardingAccountStep);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('step', {
      eyebrow: 'One last step',
      title: 'Create your first account',
      description: 'Description',
      createBtn: 'Create account',
      creationFailed: 'Failed',
      guideHint: 'Hint',
    });

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
