import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class SummarizeNoteUsecase {
  final NotesRepository repository;

  SummarizeNoteUsecase(this.repository);

  Future<Either<Failure, String>> call(String content, int noteId) async {
    return await repository.summarizeNote(content, noteId); // Pass noteId
  }
}