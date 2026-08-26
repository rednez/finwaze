import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DateTimeField } from './date-time-field';

describe('DateTimeField', () => {
  let component: DateTimeField;
  let fixture: ComponentFixture<DateTimeField>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DateTimeField],
    }).compileComponents();

    fixture = TestBed.createComponent(DateTimeField);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('inputId', 'test-date');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
