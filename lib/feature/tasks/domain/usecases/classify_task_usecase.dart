import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/tasks_repository.dart';

class ClassifyTaskUsecase {
  final TasksRepository repository;

  ClassifyTaskUsecase(this.repository);

  Future<Either<Failure, String>> call(String text) async {
    return await repository.classifyTask(text);
  }
}