class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? paymentTokens;

  AuthResult({
    required this.token,
    required this.user,
    this.paymentTokens,
  });
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);
}

class VerificationException implements Exception {
  final String message;
  VerificationException(this.message);
}

class PasswordResetException implements Exception {
  final String message;
  PasswordResetException(this.message);
}
