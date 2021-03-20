class ServerException implements Exception {}

class CacheException implements Exception {}

class ValidationException implements Exception {
  String message;

  ValidationException(this.message);
}
