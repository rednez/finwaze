import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { GuideTopicCard } from './guide-topic-card';

describe('GuideTopicCard', () => {
  let component: GuideTopicCard;
  let fixture: ComponentFixture<GuideTopicCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GuideTopicCard],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(GuideTopicCard);
    fixture.componentRef.setInput('topic', {
      key: 'wallet',
      image: 'guide/wallet.svg',
      icon: 'pi pi-wallet',
      iconClass: 'text-violet-500',
      accentClass: 'text-violet-500',
      title: 'Wallet',
      summary: 'All your accounts.',
    });
    fixture.componentRef.setInput('readCta', 'Read guide');
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('links to the topic article', () => {
    const link: HTMLAnchorElement = fixture.nativeElement.querySelector('a');

    expect(link.getAttribute('href')).toBe('/guide/wallet');
    expect(link.textContent).toContain('Wallet');
  });
});
