import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/note_entity.dart';
import '../domain/repositories/notes_repository.dart';
import '../domain/usecases/add_note_usecase.dart';
import '../domain/usecases/summarize_note_usecase.dart';
import '../domain/usecases/update_note_summary_usecase.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends HydratedBloc<NotesEvent, NotesState> {
  final NotesRepository repository;
  late final AddNoteUsecase _addNoteUsecase;
  late final SummarizeNoteUsecase _summarizeNoteUsecase;
  late final UpdateNoteSummaryUsecase _updateNoteSummaryUsecase;
  final _logger = Logger();

  NotesBloc(this.repository) : super(const NotesInitial()) {
    _addNoteUsecase = AddNoteUsecase(repository);
    _summarizeNoteUsecase = SummarizeNoteUsecase(repository);
    _updateNoteSummaryUsecase = UpdateNoteSummaryUsecase(repository);

    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<SummarizeNoteEvent>(_onSummarizeNote);
  }

  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) async {
    emit( NotesLoading());
    final result = await repository.getAllNotes();
    result.fold(
          (failure) => emit(NotesError(failure.message)),
          (notes) => emit(NotesLoaded(notes)),
    );
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    emit( NotesLoading());
    final result = await _addNoteUsecase(event.content);
    result.fold(
          (failure) => emit(NotesError(failure.message)),
          (note) {
        if (state is NotesLoaded) {
          final updatedNotes = List<NoteEntity>.from((state as NotesLoaded).notes)..add(note);
          emit(NotesLoaded(updatedNotes));
        } else {
          emit(NotesLoaded([note]));
        }
      },
    );
  }

  Future<void> _onSummarizeNote(SummarizeNoteEvent event, Emitter<NotesState> emit) async {
    // Capture previous notes before changing state
    List<NoteEntity> previousNotes = [];
    if (state is NotesLoaded) {
      previousNotes = List<NoteEntity>.from((state as NotesLoaded).notes);
    } else {
      _logger.e('Summarize called in invalid state: ${state.runtimeType}');
      emit(NotesError('Cannot summarize in current state'));
      return;
    }

    emit( NotesLoading());

    try {
      final summarizeResult = await _summarizeNoteUsecase(event.content, event.id).timeout(
        const Duration(seconds: 30),
        onTimeout: () => Left(ServerFailure()),
      );
      await summarizeResult.fold(
            (failure) async {
          _logger.e('Summarize failed: ${failure.message}');
          emit(NotesError(failure.message));
        },
            (summary) async {
          final updateResult = await _updateNoteSummaryUsecase(event.id, summary);
          updateResult.fold(
                (failure) {
              _logger.e('Update summary failed: ${failure.message}');
              emit(NotesError(failure.message));
            },
                (updatedNote) {
              final index = previousNotes.indexWhere((n) => n.id == event.id);
              if (index != -1) {
                previousNotes[index] = updatedNote;
                emit(NotesLoaded(previousNotes));
              } else {
                _logger.w('Note with id ${event.id} not found');
                emit(NotesError('Note not found'));
              }
            },
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error in summarize: $e');
      emit(NotesError('Unexpected error: $e'));
    }
  }

  @override
  NotesState? fromJson(Map<String, dynamic> json) {
    try {
      return NotesLoaded(
        (json['notes'] as List<dynamic>).map((map) => NoteEntity.fromMap(map as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(NotesState state) {
    if (state is NotesLoaded) {
      return {'notes': state.notes.map((note) => note.toMap()).toList()};
    }
    return null;
  }
}