import { inject } from '@angular/core';
import { CanMatchFn } from '@angular/router';
import { SupabaseService } from '@core/services/supabase.service';
import { AuthStore } from '@core/store/auth-store';

export const guestGuard: CanMatchFn = async (route, segments) => {
  const authStore = inject(AuthStore);
  await authStore.init();

  return !authStore.isAuthorized();
};
