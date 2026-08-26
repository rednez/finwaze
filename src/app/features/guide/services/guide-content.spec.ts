import { TestBed } from '@angular/core/testing';

import { GUIDE_TOPICS } from '../guide-topics';
import { GuideContent } from './guide-content';

describe('GuideContent', () => {
  let service: GuideContent;

  beforeEach(() => {
    service = TestBed.inject(GuideContent);
  });

  it('builds a card for every topic', () => {
    const cards = service.topicCards();

    expect(cards).toHaveLength(GUIDE_TOPICS.length);
    expect(cards[0].key).toBe(GUIDE_TOPICS[0].key);
    expect(cards[0].title).toBeTruthy();
    expect(cards[0].summary).toBeTruthy();
  });

  it('returns null for an unknown topic', () => {
    expect(service.article('nope')).toBeNull();
  });

  it('links the surrounding topics', () => {
    const first = service.article(GUIDE_TOPICS[0].key);
    const second = service.article(GUIDE_TOPICS[1].key);
    const last = service.article(GUIDE_TOPICS.at(-1)!.key);

    expect(first?.prev).toBeNull();
    expect(first?.next?.key).toBe(GUIDE_TOPICS[1].key);
    expect(second?.prev?.key).toBe(GUIDE_TOPICS[0].key);
    expect(last?.next).toBeNull();
  });
});
