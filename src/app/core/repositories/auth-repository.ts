import { inject, Injectable } from '@angular/core';
import { SupabaseService } from '@core/services/supabase.service';

@Injectable({
  providedIn: 'root',
})
export class AuthRepository {
  supabaseService = inject(SupabaseService);

  async getUser() {
    const session = await this.supabaseService.getSession();
    if (session) {
      const user = session.user;
      return {
        id: user.id,
        name: (user.user_metadata['full_name'] as string) || '',
        email: (user.email as string) || '',
        imgUrl: (user.user_metadata['avatar_url'] as string) || '',
      };
    } else {
      return null;
    }
  }

  async loginWithGoogle() {
    await this.supabaseService.signInWithGoogle();
  }

  async loginWithDemo() {
    await this.supabaseService.signInWithDemo();
  }

  async logOut() {
    await this.supabaseService.signOut();
  }
}
