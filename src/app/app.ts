import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Sidebar, TopBar } from '@layout';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Sidebar, TopBar],
  templateUrl: './app.html',
  styleUrls: ['./app.css'],
})
export class App {
  visible = signal(false);
}
