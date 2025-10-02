import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class AddNoteUsecase {
  final NotesRepository repository;

  AddNoteUsecase(this.repository);

  Future<Either<Failure, NoteEntity>> call(String content) async {
    return await repository.addNote(content);
  }
}