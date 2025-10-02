import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/datasources/notes_remote_datasource.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<Either<Failure, NoteEntity>> addNote(String content) async {
    try {
      final id = await localDataSource.addNote(content);
      final map = await localDataSource.getNoteById(id);
      return Right(NoteEntity.fromMap(map));
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<NoteEntity>>> getAllNotes() async {
    try {
      final maps = await localDataSource.getAllNotes();
      final notes = maps.map(NoteEntity.fromMap).toList();
      return Right(notes);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> summarizeNote(String content, int noteId) async {
    try {
      final summary = await remoteDataSource.summarizeNote(content, noteId);
      return Right(summary);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NoteEntity>> updateNoteSummary(int id, String summary) async {
    try {
      await localDataSource.updateNoteSummary(id, summary);
      final map = await localDataSource.getNoteById(id);
      return Right(NoteEntity.fromMap(map));
    } on Exception {
      return Left(ServerFailure());
    }
  }
}