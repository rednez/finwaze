import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Transfer } from './transfer';
import { MessageService } from 'primeng/api';

describe('Transfer', () => {
  let component: Transfer;
  let fixture: ComponentFixture<Transfer>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Transfer],
      providers: [MessageService, provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(Transfer);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
