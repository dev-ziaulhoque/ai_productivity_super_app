import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class UpdateNoteSummaryUsecase {
  final NotesRepository repository;

  UpdateNoteSummaryUsecase(this.repository);

  Future<Either<Failure, NoteEntity>> call(int id, String summary) async {
    return await repository.updateNoteSummary(id, summary);
  }
}