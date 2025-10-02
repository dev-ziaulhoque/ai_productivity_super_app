import 'package:dartz/dartz.dart';
import 'package:ai_productivity_super_app/core/error/failures.dart';
import '../repositories/tasks_repository.dart';

class DeleteTaskUsecase {
  final TasksRepository repository;

  DeleteTaskUsecase(this.repository);

  Future<Either<Failure, bool>> call(int id) async {
    try {
      final result = await repository.deleteTask(id);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to delete task: $e'));
    }
  }
}