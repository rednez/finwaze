import { Service, signal } from '@angular/core';

@Service()
export class DemoModeService {
  private static readonly KEY = 'demo_mode';

  readonly isDemo = signal<boolean>(
    localStorage.getItem(DemoModeService.KEY) === 'true',
  );

  enable(): void {
    localStorage.setItem(DemoModeService.KEY, 'true');
    this.isDemo.set(true);
  }

  disable(): void {
    localStorage.removeItem(DemoModeService.KEY);
    this.isDemo.set(false);
  }
}
