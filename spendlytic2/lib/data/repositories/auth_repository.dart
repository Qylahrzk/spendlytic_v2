import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get the current user (if already logged in)
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream to listen for auth changes (Login, Logout, Token Refresh)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign In Logic
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login Failed: ${e.toString()}');
    }
  }

  /// Sign Up Logic
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // Return the response!
      return await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      throw Exception('Sign Up Failed: ${e.toString()}');
    }
  }

  /// Sign Out Logic
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout Failed: ${e.toString()}');
    }
  }
}
