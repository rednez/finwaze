import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GuideTips } from './guide-tips';

describe('GuideTips', () => {
  let component: GuideTips;
  let fixture: ComponentFixture<GuideTips>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideTips],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideTips);
    fixture.componentRef.setInput('label', 'Best practices');
    fixture.componentRef.setInput('tips', ['One', 'Two', 'Three']);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('renders every tip', () => {
    expect(fixture.nativeElement.querySelectorAll('li')).toHaveLength(3);
  });
});
