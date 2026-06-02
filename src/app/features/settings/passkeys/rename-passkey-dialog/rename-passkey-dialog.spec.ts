import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RenamePasskeyDialog } from './rename-passkey-dialog';

describe('RenamePasskeyDialog', () => {
  let component: RenamePasskeyDialog;
  let fixture: ComponentFixture<RenamePasskeyDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RenamePasskeyDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(RenamePasskeyDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
