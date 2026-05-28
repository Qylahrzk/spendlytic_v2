import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/biometric_service.dart';
import 'auth_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepo;
  final BiometricService _biometricService; // Dependency Injection
  late StreamSubscription _authSubscription;

  // Flag to track if the user is manually logging in right now
  bool _isManualFlow = false;

  AuthenticationCubit(this._authRepo, this._biometricService)
    : super(AuthenticationInitial()) {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    // 1. App Start (Cold Boot) -> Check if we have a session
    final currentUser = _authRepo.currentUser;
    if (currentUser != null) {
      // Session exists, but we require Biometric to "unlock" the UI
      emit(
        AuthenticationAuthenticated(
          userId: currentUser.id,
          email: currentUser.email ?? '',
          requiresBiometric: true,
        ),
      );
    } else {
      emit(AuthenticationUnauthenticated());
    }

    // 2. Listen for Session Changes (Supabase Stream)
    _authSubscription = _authRepo.authStateChanges.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        // If this was a manual login (User typed password), don't lock.
        // If it was a background refresh or cold boot, lock it.
        final shouldLock = !_isManualFlow;

        emit(
          AuthenticationAuthenticated(
            userId: user.id,
            email: user.email ?? '',
            requiresBiometric: shouldLock,
          ),
        );

        // Reset the flag immediately
        _isManualFlow = false;
      } else {
        emit(AuthenticationUnauthenticated());
      }
    });
  }

  /// NEW: Triggered when user clicks the Face ID button on Login Screen
  Future<void> loginWithBiometrics() async {
    // 1. Check if there is a session to unlock
    final currentUser = _authRepo.currentUser;

    if (currentUser == null) {
      emit(
        AuthenticationError(
          "Please log in with password first to enable Face ID.",
        ),
      );
      emit(AuthenticationUnauthenticated());
      return;
    }

    // 2. Run Biometric Check
    final success = await _biometricService.authenticate();

    if (success) {
      _isManualFlow = true; // Treat this as a manual entry so we don't re-lock

      // Update state to "Authenticated & Unlocked"
      emit(
        AuthenticationAuthenticated(
          userId: currentUser.id,
          email: currentUser.email ?? '',
          requiresBiometric: false, // UNLOCKED
        ),
      );
    } else {
      emit(AuthenticationError("Biometric authentication failed."));
      // We keep the previous state (likely Authenticated w/ requiresBiometric: true)
      // or re-emit it to be safe:
      emit(
        AuthenticationAuthenticated(
          userId: currentUser.id,
          email: currentUser.email ?? '',
          requiresBiometric: true,
        ),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthenticationLoading());
    try {
      _isManualFlow = true;
      await _authRepo.signIn(email: email, password: password);
    } catch (e) {
      _isManualFlow = false;
      emit(AuthenticationError(e.toString()));
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthenticationLoading());
    try {
      _isManualFlow = true;

      // 1. Create Auth User
      final response = await _authRepo.signUp(email: email, password: password);

      // Check if Email Confirmation is ON
      if (response.session == null) {
        _isManualFlow = false;
        emit(
          AuthenticationError(
            "Account created! Please confirm your email to login.",
          ),
        );
        emit(AuthenticationUnauthenticated());
        return;
      }

      // 2. Create Profile (Safe Mode)
      try {
        final user = response.user;
        if (user != null) {
          final supabase = Supabase.instance.client;
          await supabase.from('profiles').upsert({
            'id': user.id,
            'email': email,
            'full_name': 'New Student',
            'default_currency': 'MYR (RM)',
            'sorting': 'Date',
            'summary': 'Average',
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (profileError) {
        print("Profile creation warning: $profileError");
      }
    } catch (e) {
      _isManualFlow = false;
      emit(AuthenticationError("Sign Up Failed: $e"));
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> signOut() async {
    _isManualFlow = false;
    await _authRepo.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
