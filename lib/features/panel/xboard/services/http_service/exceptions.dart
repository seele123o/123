// lib/features/panel/xboard/services/http_service/exceptions.dart// lib/features/panel/xboard/services/http_service/exceptions.dart
class ConnectionException implements Exception {
  final String message;
  final dynamic originalError;

  ConnectionException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => message;
}

class RequestException implements Exception {
  final String message;
  final dynamic response;

  RequestException(this.message, [this.response]);

  @override
  String toString() => message;
}
