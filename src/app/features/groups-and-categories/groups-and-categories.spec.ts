import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupsAndCategories } from './groups-and-categories';

describe('GroupsAndCategories', () => {
  let component: GroupsAndCategories;
  let fixture: ComponentFixture<GroupsAndCategories>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GroupsAndCategories],
    }).compileComponents();

    fixture = TestBed.createComponent(GroupsAndCategories);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
