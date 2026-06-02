import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UnderConstruction } from './under-construction';

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: (query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: noop,
    removeListener: noop,
    addEventListener: noop,
    removeEventListener: noop,
    dispatchEvent: () => false,
  }),
});

describe('UnderConstruction', () => {
  let component: UnderConstruction;
  let fixture: ComponentFixture<UnderConstruction>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UnderConstruction],
    }).compileComponents();

    fixture = TestBed.createComponent(UnderConstruction);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
