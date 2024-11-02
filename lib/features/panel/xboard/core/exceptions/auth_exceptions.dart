// lib/features/panel/xboard/core/exceptions/auth_exceptions.dart

import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/exceptions.dart';

// 基础认证异常，继承自 RequestException
class AuthException extends RequestException {
  AuthException(String message, [dynamic response]) : super(message, response);
}

// 认证令牌异常
class AuthTokenException extends AuthException {
  final AuthTokenError errorType;

  AuthTokenException(this.errorType, [String? message])
    : super(message ?? errorType.message);

  factory AuthTokenException.expired() =>
    AuthTokenException(AuthTokenError.expired);

  factory AuthTokenException.invalid() =>
    AuthTokenException(AuthTokenError.invalid);

  factory AuthTokenException.missing() =>
    AuthTokenException(AuthTokenError.missing);
}

enum AuthTokenError {
  expired('Token has expired'),
  invalid('Invalid token'),
  missing('Token not found');

  final String message;
  const AuthTokenError(this.message);
}

// 认证失败异常
class AuthenticationException extends AuthException {
  AuthenticationException(String message, [dynamic response])
    : super(message, response);

  factory AuthenticationException.invalidCredentials() =>
    AuthenticationException('Invalid username or password');

  factory AuthenticationException.accountLocked() =>
    AuthenticationException('Account is locked');

  factory AuthenticationException.tooManyAttempts() =>
    AuthenticationException('Too many login attempts');
}

// 注册异常
class RegistrationException extends AuthException {
  RegistrationException(String message, [dynamic response])
    : super(message, response);

  factory RegistrationException.emailExists() =>
    RegistrationException('Email already exists');

  factory RegistrationException.invalidInviteCode() =>
    RegistrationException('Invalid invite code');

  factory RegistrationException.emailVerificationRequired() =>
    RegistrationException('Email verification required');
}

// 邮箱验证异常
class EmailVerificationException extends AuthException {
  EmailVerificationException(String message, [dynamic response])
    : super(message, response);

  factory EmailVerificationException.codeMismatch() =>
    EmailVerificationException('Verification code does not match');

  factory EmailVerificationException.codeExpired() =>
    EmailVerificationException('Verification code has expired');

  factory EmailVerificationException.tooManyAttempts() =>
    EmailVerificationException('Too many verification attempts');
}

// 密码重置异常
class PasswordResetException extends AuthException {
  PasswordResetException(String message, [dynamic response])
    : super(message, response);

  factory PasswordResetException.emailNotFound() =>
    PasswordResetException('Email not found');

  factory PasswordResetException.invalidCode() =>
    PasswordResetException('Invalid reset code');

  factory PasswordResetException.expired() =>
    PasswordResetException('Reset code has expired');
}

// 会话异常
class SessionException extends AuthException {
  SessionException(String message, [dynamic response])
    : super(message, response);

  factory SessionException.expired() =>
    SessionException('Session has expired');

  factory SessionException.invalidated() =>
    SessionException('Session has been invalidated');

  factory SessionException.concurrent() =>
    SessionException('Concurrent session detected');
}

// 权限异常
class PermissionException extends AuthException {
  PermissionException(String message, [dynamic response])
    : super(message, response);

  factory PermissionException.insufficientPermissions() =>
    PermissionException('Insufficient permissions');

  factory PermissionException.resourceForbidden() =>
    PermissionException('Access to resource forbidden');
}

// 帮助函数
extension AuthExceptionHandler on AuthException {
  String toUserFriendlyMessage() {
    if (this is AuthenticationException) {
      return '登录失败：${message}';
    } else if (this is RegistrationException) {
      return '注册失败：${message}';
    } else if (this is EmailVerificationException) {
      return '邮箱验证失败：${message}';
    } else if (this is PasswordResetException) {
      return '重置密码失败：${message}';
    } else if (this is SessionException) {
      return '会话错误：${message}';
    } else if (this is PermissionException) {
      return '权限错误：${message}';
    } else if (this is AuthTokenException) {
      return '认证令牌错误：${message}';
    }
    return message;
  }
}