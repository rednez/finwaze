import { Injectable } from '@angular/core';
import { environment } from '@env';
import {
  createClient,
  Session,
  SupabaseClient,
  User,
} from '@supabase/supabase-js';

@Injectable({
  providedIn: 'root',
})
export class SupabaseService {
  private supabase: SupabaseClient;

  constructor() {
    this.supabase = createClient(
      environment.supabase.url,
      environment.supabase.publicKey,
      {
        auth: {
          detectSessionInUrl: true,
        },
      },
    );
  }

  get client(): SupabaseClient {
    return this.supabase;
  }

  async signInWithGoogle() {
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
    const { error } = await this.supabase.auth.signOut();
    if (error) {
      console.error('Error signing out:', error);
      throw error;
    }
  }

  async getSession(): Promise<Session | null> {
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
