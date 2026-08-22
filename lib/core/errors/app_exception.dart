abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class AuthorizationException extends AppException {
  const AuthorizationException(
    super.message, {
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.code = 'NOT_FOUND',
    super.details,
  });
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

class OfflineException extends AppException {
  const OfflineException(
    super.message, {
    super.code = 'OFFLINE',
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code = 'SERVER_ERROR',
    super.details,
  });
}
