import { IMAGE_LOADER } from '@angular/common';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { appImageLoader } from '../../../../core/app-image-loader';
import { OnboardingInfoStep } from './onboarding-info-step';

describe('OnboardingInfoStep', () => {
  let component: OnboardingInfoStep;
  let fixture: ComponentFixture<OnboardingInfoStep>;

  beforeEach(async () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    await TestBed.configureTestingModule({
      imports: [OnboardingInfoStep],
      providers: [{ provide: IMAGE_LOADER, useValue: appImageLoader }],
    }).compileComponents();

    fixture = TestBed.createComponent(OnboardingInfoStep);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('step', {
      eyebrow: 'Welcome',
      title: 'Title',
      description: 'Description',
      bullets: ['One', 'Two'],
      image: { name: 'welcome', width: 1866, height: 1208 },
    });
    fixture.componentRef.setInput('showBack', false);
    fixture.componentRef.setInput('nextLabel', 'Next');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('emits skip when the skip button is clicked', () => {
    fixture.detectChanges();

    let skipped = false;
    component.skip.subscribe(() => (skipped = true));

    const skipButton = Array.from<HTMLButtonElement>(
      fixture.nativeElement.querySelectorAll('button'),
    ).find((button) => button.textContent?.trim() === 'Skip');

    skipButton?.click();

    expect(skipped).toBe(true);
  });
});
