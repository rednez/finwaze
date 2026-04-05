import { inject, Injectable } from '@angular/core';
import { environment } from '@env';
import {
  createClient,
  Session,
  SupabaseClient,
  User,
} from '@supabase/supabase-js';
import { DemoModeService } from './demo-mode/demo-mode.service';
import { DemoSupabaseClient } from './demo-mode/demo-supabase-client';

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
          },
        },
      );
    } catch (error) {
      console.log('Errro initializing Supabase client:', error);
    }
  }

  get client(): SupabaseClient {
    if (this.demoModeService.isDemo()) {
      // DemoSupabaseClient handles all repository call patterns without hitting the network
      return this.demoClient as unknown as SupabaseClient;
    }

    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    return this.supabase;
  }

  async signInWithGoogle() {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    const { error } = await this.supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: 'http://localhost:4200/dashboard' },
    });

    if (error) {
      console.error('Error signing in with Google:', error);
      throw error;
    }
  }

  async signInWithDemo() {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    const { error } = await this.supabase.auth.signInWithPassword({
      email: 'demo@mail.com',
      password: 'password1234',
    });

    if (error) {
      console.error('Error signing in with demo account:', error);
      throw error;
    }
  }

  async signOut() {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    const { error } = await this.supabase.auth.signOut();
    if (error) {
      console.error('Error signing out:', error);
      throw error;
    }
  }

  async getSession(): Promise<Session | null> {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    const {
      data: { session },
      error,
    } = await this.supabase.auth.getSession();
    if (error) {
      console.error('Error getting session:', error);
      return null;
    }
    return session;
  }

  async getUser(): Promise<User | null> {
    if (!this.supabase) {
      throw new Error('Supabase client is not initialized');
    }

    const {
      data: { user },
      error,
    } = await this.supabase.auth.getUser();
    if (error) {
      console.error('Error getting user:', error);
      return null;
    }
    return user;
  }
}
