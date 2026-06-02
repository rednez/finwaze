import { inject, Injectable } from '@angular/core';
import { environment } from '@env';
import {
  createClient,
  PasskeyListItem,
  Session,
  SupabaseClient,
  User,
} from '@supabase/supabase-js';
import { DemoModeService } from './demo-mode/demo-mode.service';
import { DemoSupabaseClient } from './demo-mode/demo-supabase-client';

export type Passkey = PasskeyListItem;

@Injectable({
  providedIn: 'root',
})
export class SupabaseService {
  private supabase?: SupabaseClient;
  private readonly demoModeService = inject(DemoModeService);
  private readonly demoClient = new DemoSupabaseClient();

  constructor() {
    try {
      this.supabase = createClient(
        environment.supabase.url,
        environment.supabase.publicKey,
        {
          auth: {
            detectSessionInUrl: true,
            experimental: { passkey: true },
          },
        },
      );
    } catch (error) {
      console.log('Error initializing Supabase client:', error);
    }
  }

  get client(): SupabaseClient {
    if (this.demoModeService.isDemo()) {
      // DemoSupabaseClient handles all repository call patterns without hitting the network
      return this.demoClient as unknown as SupabaseClient;
    }

    return this.getClient();
  }

  private getClient(): SupabaseClient {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }
    return this.supabase;
  }

  async signInWithGoogle() {
    const { error } = await this.getClient().auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: 'http://localhost:4200/dashboard' },
    });

    if (error) {
      console.error('Error signing in with Google:', error);
      throw error;
    }
  }

  async signInWithDemo() {
    const { error } = await this.getClient().auth.signInWithPassword({
      email: 'demo@mail.com',
      password: 'password1234',
    });

    if (error) {
      console.error('Error signing in with demo account:', error);
      throw error;
    }
  }

  async signOut() {
    const { error } = await this.getClient().auth.signOut();
    if (error) {
      console.error('Error signing out:', error);
      throw error;
    }
  }

  async getSession(): Promise<Session | null> {
    const {
      data: { session },
      error,
    } = await this.getClient().auth.getSession();
    if (error) {
      console.error('Error getting session:', error);
      return null;
    }
    return session;
  }

  async getUser(): Promise<User | null> {
    const {
      data: { user },
      error,
    } = await this.getClient().auth.getUser();
    if (error) {
      console.error('Error getting user:', error);
      return null;
    }
    return user;
  }

  async signUp(credits: { email: string; password: string }) {
    return this.getClient().auth.signUp(credits);
  }

  async signInWithEmail(credits: { email: string; password: string }) {
    return this.getClient().auth.signInWithPassword(credits);
  }

  async resetPasswordForEmail(email: string) {
    return this.getClient().auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/change-password`,
    });
  }

  async updatePassword(password: string) {
    return this.getClient().auth.updateUser({ password });
  }

  async signInWithPasskey() {
    return this.getClient().auth.signInWithPasskey();
  }

  async registerPasskey() {
    return this.getClient().auth.registerPasskey();
  }

  async listPasskeys() {
    return this.getClient().auth.passkey.list();
  }

  async renamePasskey(passkeyId: string, friendlyName: string) {
    return this.getClient().auth.passkey.update({ passkeyId, friendlyName });
  }

  async deletePasskey(passkeyId: string) {
    return this.getClient().auth.passkey.delete({ passkeyId });
  }
}
