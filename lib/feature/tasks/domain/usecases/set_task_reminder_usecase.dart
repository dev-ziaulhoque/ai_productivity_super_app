import 'package:dartz/dartz.dart';
import 'package:ai_productivity_super_app/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class SetTaskReminderUsecase {
  final TasksRepository repository;

  SetTaskReminderUsecase(this.repository);

  Future<Either<Failure, TaskEntity>> call(int id, DateTime? reminderTimestamp) async {
    try {
      final result = await repository.setTaskReminder(id, reminderTimestamp);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to set reminder: $e'));
    }
  }
}