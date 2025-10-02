import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/tasks_repository.dart';

class UpdateTaskCompletedUsecase {
  final TasksRepository repository;

  UpdateTaskCompletedUsecase(this.repository);

  Future<Either<Failure, TaskEntity>> call(int id, bool isCompleted) async {
    return await repository.updateTaskCompleted(id, isCompleted);
  }
}