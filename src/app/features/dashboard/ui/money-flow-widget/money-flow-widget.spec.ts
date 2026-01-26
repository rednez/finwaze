import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MoneyFlowWidget } from './money-flow-widget';

describe('MoneyFlowWidget', () => {
  let component: MoneyFlowWidget;
  let fixture: ComponentFixture<MoneyFlowWidget>;

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
      imports: [MoneyFlowWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(MoneyFlowWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
