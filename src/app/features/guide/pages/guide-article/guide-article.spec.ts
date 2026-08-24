import { IMAGE_LOADER } from '@angular/common';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { appImageLoader } from '../../../../core/app-image-loader';

import { GuideArticle } from './guide-article';

describe('GuideArticle', () => {
  let component: GuideArticle;
  let fixture: ComponentFixture<GuideArticle>;

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
      imports: [GuideArticle],
      providers: [
        provideRouter([{ path: 'guide', children: [] }]),
        { provide: IMAGE_LOADER, useValue: appImageLoader },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideArticle);
    fixture.componentRef.setInput('topic', 'transactions');
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('renders a valid topic', () => {
    expect(fixture.nativeElement.querySelector('article')).toBeTruthy();
  });

  it('renders nothing for an unknown topic', async () => {
    fixture.componentRef.setInput('topic', 'nope');
    await fixture.whenStable();

    expect(fixture.nativeElement.querySelector('article')).toBeNull();
  });
});
