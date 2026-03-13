import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DemoButton } from './demo-button';

describe('DemoButton', () => {
  let component: DemoButton;
  let fixture: ComponentFixture<DemoButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DemoButton],
    }).compileComponents();

    fixture = TestBed.createComponent(DemoButton);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
