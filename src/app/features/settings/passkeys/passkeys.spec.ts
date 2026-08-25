import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MessageService } from '@openng/optimus-ui/api';
import { Passkeys } from './passkeys';

describe('Passkeys', () => {
  let component: Passkeys;
  let fixture: ComponentFixture<Passkeys>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Passkeys],
      providers: [MessageService],
    }).compileComponents();

    fixture = TestBed.createComponent(Passkeys);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
