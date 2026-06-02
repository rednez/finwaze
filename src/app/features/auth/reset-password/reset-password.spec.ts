import { provideRouter } from '@angular/router';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ResetPassword } from './reset-password';
import { MessageService } from 'primeng/api';

describe('ResetPassword', () => {
  let component: ResetPassword;
  let fixture: ComponentFixture<ResetPassword>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResetPassword],
      providers: [MessageService, provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(ResetPassword);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
