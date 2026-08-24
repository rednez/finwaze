import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { GuideArticleNav } from './guide-article-nav';

describe('GuideArticleNav', () => {
  let component: GuideArticleNav;
  let fixture: ComponentFixture<GuideArticleNav>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideArticleNav],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideArticleNav);
    fixture.componentRef.setInput('prev', { key: 'wallet', title: 'Wallet' });
    fixture.componentRef.setInput('next', { key: 'goals', title: 'Goals' });
    fixture.componentRef.setInput('backLabel', 'All guides');
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('links to both siblings', () => {
    const links: HTMLAnchorElement[] = Array.from(
      fixture.nativeElement.querySelectorAll('a'),
    );

    expect(links.map((link) => link.getAttribute('href'))).toEqual([
      '/guide/wallet',
      '/guide/goals',
    ]);
  });

  it('falls back to the hub when there is no next topic', async () => {
    fixture.componentRef.setInput('next', null);
    await fixture.whenStable();

    const links: HTMLAnchorElement[] = Array.from(
      fixture.nativeElement.querySelectorAll('a'),
    );

    expect(links.at(-1)?.getAttribute('href')).toBe('/guide');
    expect(links.at(-1)?.textContent).toContain('All guides');
  });
});
