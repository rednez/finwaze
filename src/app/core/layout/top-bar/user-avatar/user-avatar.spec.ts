import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UserAvatar } from './user-avatar';

describe('UserAvatar', () => {
  let component: UserAvatar;
  let fixture: ComponentFixture<UserAvatar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserAvatar],
    }).compileComponents();

    fixture = TestBed.createComponent(UserAvatar);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('name', 'John Doe');
    fixture.componentRef.setInput('email', 'john@gmail.com');
    fixture.componentRef.setInput('imgUrl', 'https://example.com/john.jpg');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
