import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FilledBlock } from './filled-block';

describe('FilledBlock', () => {
  let component: FilledBlock;
  let fixture: ComponentFixture<FilledBlock>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FilledBlock]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FilledBlock);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
