// Abstract Exception (optional, but can be added for consistency)
abstract class Exception {
  final String message;
  Exception(this.message);
}

// ServerException class
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

// ValidationException class
class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation error']);
}