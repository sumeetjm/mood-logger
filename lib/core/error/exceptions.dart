class ServerException implements Exception {}

class CacheException implements Exception {}

class NoInternetException implements Exception {
  final String message = 'Unable to connect';
}

class ValidationException implements Exception {
  String message;

  ValidationException(this.message);
}
