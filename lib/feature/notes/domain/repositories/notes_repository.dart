import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<Either<Failure, NoteEntity>> addNote(String content);
  Future<Either<Failure, List<NoteEntity>>> getAllNotes();
  Future<Either<Failure, String>> summarizeNote(String content, int noteId);
  Future<Either<Failure, NoteEntity>> updateNoteSummary(int id, String summary);
}