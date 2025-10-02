import 'package:dartz/dartz.dart';
import 'package:ai_productivity_super_app/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class UpdateTaskCategoryUsecase {
  final TasksRepository repository;

  UpdateTaskCategoryUsecase(this.repository);

  Future<Either<Failure, TaskEntity>> call(int id, String category) async {
    try {
      final result = await repository.updateTaskCategory(id, category);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to update category: $e'));
    }
  }
}