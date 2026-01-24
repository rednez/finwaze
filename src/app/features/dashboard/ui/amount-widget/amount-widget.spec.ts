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
    fixture.componentRef.setInput('amount', 123.43);
    fixture.componentRef.setInput('percent', 12.1);

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
