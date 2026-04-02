import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class GoalsRepository {
  private readonly supabase = inject(SupabaseService);
}
