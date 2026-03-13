import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CreateBudget } from './create-budget';

describe('CreateBudget', () => {
  let component: CreateBudget;
  let fixture: ComponentFixture<CreateBudget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CreateBudget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CreateBudget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
