class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  
  const NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}

class PermissionException implements Exception {
  final String message;
  
  const PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class TimeoutException implements Exception {
  final String message;
  
  const TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

class UnknownException implements Exception {
  final String message;
  
  const UnknownException(this.message);
  
  @override
  String toString() => 'UnknownException: $message';
}
