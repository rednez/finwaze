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
        provider: (user.app_metadata['provider'] as string) || '',
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

  async signUp(credits: { email: string; password: string }) {
    return this.supabaseService.signUp(credits);
  }

  async loginWithEmail(credits: { email: string; password: string }) {
    return this.supabaseService.signInWithEmail(credits);
  }

  async resetPasswordForEmail(email: string) {
    return this.supabaseService.resetPasswordForEmail(email);
  }

  async updatePassword(password: string) {
    return this.supabaseService.updatePassword(password);
  }

  async signInWithPasskey() {
    return this.supabaseService.signInWithPasskey();
  }

  async registerPasskey() {
    return this.supabaseService.registerPasskey();
  }

  async listPasskeys() {
    return this.supabaseService.listPasskeys();
  }

  async renamePasskey(passkeyId: string, friendlyName: string) {
    return this.supabaseService.renamePasskey(passkeyId, friendlyName);
  }

  async deletePasskey(passkeyId: string) {
    return this.supabaseService.deletePasskey(passkeyId);
  }
}
