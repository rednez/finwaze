import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AmountWidget } from './amount-widget';

describe('AmountWidget', () => {
  let component: AmountWidget;
  let fixture: ComponentFixture<AmountWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AmountWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(AmountWidget);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('title', 'Test Title');
    fixture.componentRef.setInput('currency', 'USD');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
