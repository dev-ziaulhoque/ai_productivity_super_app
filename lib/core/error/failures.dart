abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server failure']) : super(message);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}