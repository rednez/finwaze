import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NamePromptDialog } from './name-prompt-dialog';

describe('NamePromptDialog', () => {
  let component: NamePromptDialog;
  let fixture: ComponentFixture<NamePromptDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NamePromptDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(NamePromptDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
