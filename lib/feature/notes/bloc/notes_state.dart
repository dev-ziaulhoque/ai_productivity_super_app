part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteEntity> notes;
  const NotesLoaded(this.notes);

  @override
  List<Object> get props => [notes];
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);

  @override
  List<Object> get props => [message];
}