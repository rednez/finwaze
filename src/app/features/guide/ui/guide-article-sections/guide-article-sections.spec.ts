import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GuideArticleSections } from './guide-article-sections';

describe('GuideArticleSections', () => {
  let component: GuideArticleSections;
  let fixture: ComponentFixture<GuideArticleSections>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideArticleSections],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideArticleSections);
    fixture.componentRef.setInput('sections', [
      { heading: 'First', body: 'Body' },
      { heading: 'Second', body: 'Body' },
    ]);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('renders a section per entry', () => {
    expect(fixture.nativeElement.querySelectorAll('section')).toHaveLength(2);
  });
});
