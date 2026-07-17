/// Exceptions are thrown only inside the **data** layer (datasources).
/// Repositories catch them and map them to a [Failure] — no exception
/// should ever cross into domain/presentation code.
class ServerException implements Exception {
  ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection']);
  final String message;
}

class UnauthorizedException implements Exception {
  UnauthorizedException([this.message = 'Session expired, please log in again']);
  final String message;
}
