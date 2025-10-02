import 'package:dartz/dartz.dart';
import 'package:ai_productivity_super_app/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class AddTaskUsecase {
  final TasksRepository repository;

  AddTaskUsecase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String title, {String? description, DateTime? deadline}) async {
    try {
      final result = await repository.addTask(title, description: description, deadline: deadline);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to add task: $e'));
    }
  }
}