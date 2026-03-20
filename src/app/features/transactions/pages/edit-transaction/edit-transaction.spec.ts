import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute, provideRouter } from '@angular/router';

import { EditTransaction } from './edit-transaction';

const mockActivatedRoute = {
  snapshot: {
    url: [{ path: 'edit' }],
    paramMap: { get: () => null },
  },
};

describe('EditTransaction', () => {
  let component: EditTransaction;
  let fixture: ComponentFixture<EditTransaction>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [EditTransaction],
      providers: [
        provideRouter([]),
        { provide: ActivatedRoute, useValue: mockActivatedRoute },
      ],
    })
    .compileComponents();

    fixture = TestBed.createComponent(EditTransaction);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
