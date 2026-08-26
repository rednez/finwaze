import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MessageService } from '@openng/optimus-ui/api';
import { Onboarding } from './onboarding';

describe('Onboarding', () => {
  let component: Onboarding;
  let fixture: ComponentFixture<Onboarding>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Onboarding],
      providers: [MessageService],
    }).compileComponents();

    fixture = TestBed.createComponent(Onboarding);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('skip jumps directly to the account creation step', () => {
    component['skip']();

    expect(component['currentStep']()).toBe(component['totalSteps']() - 1);
    expect(component['isAccountStep']()).toBe(true);
  });
});
