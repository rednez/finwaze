import { provideRouter } from '@angular/router';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Signup } from './signup';
import { MessageService } from 'primeng/api';

describe('Signup', () => {
  let component: Signup;
  let fixture: ComponentFixture<Signup>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Signup],
      providers: [MessageService, provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(Signup);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
