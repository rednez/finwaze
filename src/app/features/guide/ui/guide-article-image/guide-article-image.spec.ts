import { IMAGE_LOADER } from '@angular/common';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ThemeService } from '@core/services/theme.service';

import { appImageLoader } from '../../../../core/app-image-loader';
import { GuideArticleImage } from './guide-article-image';

describe('GuideArticleImage', () => {
  let component: GuideArticleImage;
  let fixture: ComponentFixture<GuideArticleImage>;

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
      imports: [GuideArticleImage],
      providers: [{ provide: IMAGE_LOADER, useValue: appImageLoader }],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideArticleImage);
    fixture.componentRef.setInput('topic', {
      key: 'wallet',
      image: { width: 1866, height: 1050 },
      icon: 'pi pi-wallet',
      iconClass: 'text-violet-500',
      accentClass: 'text-violet-500',
    });
    fixture.componentRef.setInput('alt', 'Wallet');
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('requests the light asset for the topic', () => {
    const img: HTMLImageElement = fixture.nativeElement.querySelector('img');

    expect(img.getAttribute('src')).toContain('finwaze/guide/wallet-light');
    expect(img.getAttribute('alt')).toBe('Wallet');
  });

  it('switches to the dark asset with the theme', async () => {
    TestBed.inject(ThemeService).setTheme('dark');
    await fixture.whenStable();

    const img: HTMLImageElement = fixture.nativeElement.querySelector('img');

    expect(img.getAttribute('src')).toContain('finwaze/guide/wallet-dark');
  });
});
