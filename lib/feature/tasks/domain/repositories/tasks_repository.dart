import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TasksRepository {
  Future<Either<Failure, TaskEntity>> addTask(String title, {String? description, String? category, DateTime? deadline});
  Future<Either<Failure, List<TaskEntity>>> getAllTasks();
  Future<Either<Failure, String>> classifyTask(String text);
  Future<Either<Failure, TaskEntity>> updateTaskCategory(int id, String category);
  Future<Either<Failure, TaskEntity>> updateTaskCompleted(int id, bool isCompleted);
  Future<Either<Failure, bool>> deleteTask(int id); // New method
  Future<Either<Failure, TaskEntity>> setTaskReminder(int id, DateTime? reminderTimestamp); // New method
}