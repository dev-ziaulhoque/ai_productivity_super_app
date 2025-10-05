// Abstract Failure class
abstract class Failure {
  final String message;
  Failure(this.message);
}

// ServerFailure class
class ServerFailure extends Failure {
  ServerFailure([String message = 'Server failure']) : super(message);
}

// ValidationFailure class
class ValidationFailure extends Failure {
  ValidationFailure([String message = 'Validation failed']) : super(message);
}