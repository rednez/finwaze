import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SidebarNavItem } from './sidebar-nav-item';

describe('SidebarNavItem', () => {
  let component: SidebarNavItem;
  let fixture: ComponentFixture<SidebarNavItem>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SidebarNavItem],
    }).compileComponents();

    fixture = TestBed.createComponent(SidebarNavItem);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('label', 'Test Label');
    fixture.componentRef.setInput('icon', 'test-icon');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
