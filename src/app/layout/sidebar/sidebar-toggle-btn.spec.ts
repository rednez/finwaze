import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SidebarToggleBtn } from './sidebar-toggle-btn';

describe('SidebarToggleBtn', () => {
  let component: SidebarToggleBtn;
  let fixture: ComponentFixture<SidebarToggleBtn>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SidebarToggleBtn]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SidebarToggleBtn);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
