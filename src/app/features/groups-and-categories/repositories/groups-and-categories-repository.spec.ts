import { TestBed } from '@angular/core/testing';
import { GroupsAndCategoriesRepository } from './groups-and-categories-repository';

describe('GroupsAndCategoriesRepository', () => {
  let service: GroupsAndCategoriesRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(GroupsAndCategoriesRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
