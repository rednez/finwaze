import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GuideQuickStart } from './guide-quick-start';

describe('GuideQuickStart', () => {
  let component: GuideQuickStart;
  let fixture: ComponentFixture<GuideQuickStart>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideQuickStart],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideQuickStart);
    fixture.componentRef.setInput('title', 'Quick start');
    fixture.componentRef.setInput('steps', ['One', 'Two']);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('renders one numbered item per step', () => {
    expect(fixture.nativeElement.querySelectorAll('li')).toHaveLength(2);
  });
});
