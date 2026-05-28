abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String userId;
  final String email;
  final bool requiresBiometric; // ✅ ADD THIS FLAG

  AuthenticationAuthenticated({
    required this.userId,
    required this.email,
    this.requiresBiometric = true, // Default to TRUE (Safety First)
  });
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;
  AuthenticationError(this.message);
}
