import { Component, inject } from '@angular/core';
import { GuideContent } from '../../services';
import { GuideQuickStart, GuideTopicCard } from '../../ui';

@Component({
  imports: [GuideQuickStart, GuideTopicCard],
  templateUrl: './guide-hub.html',
})
export class GuideHub {
  private readonly content = inject(GuideContent);

  protected readonly hub = this.content.hub;
  protected readonly readCta = this.content.readCta;
  protected readonly topics = this.content.topicCards;
}
