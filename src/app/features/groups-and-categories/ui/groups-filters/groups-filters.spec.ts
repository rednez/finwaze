import { ComponentFixture, TestBed } from '@angular/core/testing';
import { GroupsFilters } from './groups-filters';

describe('GroupsFilters', () => {
  let component: GroupsFilters;
  let fixture: ComponentFixture<GroupsFilters>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GroupsFilters],
    }).compileComponents();

    fixture = TestBed.createComponent(GroupsFilters);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
