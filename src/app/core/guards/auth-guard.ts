import { inject } from '@angular/core';
import { CanActivateFn, RedirectCommand, Router } from '@angular/router';
import { SupabaseService } from '@core/services/supabase.service';

export const authGuard: CanActivateFn = async (route, segments) => {
  const router = inject(Router);
  const supabaseService = inject(SupabaseService);

  const session = await supabaseService.getSession();

  if (!session) {
    return new RedirectCommand(router.parseUrl('/login'));
  } else {
    return true;
  }
};
