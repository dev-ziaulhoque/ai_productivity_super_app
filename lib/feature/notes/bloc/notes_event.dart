part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotesEvent extends NotesEvent {
  const LoadNotesEvent();
}

class AddNoteEvent extends NotesEvent {
  final String content;
  const AddNoteEvent(this.content);

  @override
  List<Object> get props => [content];
}

class SummarizeNoteEvent extends NotesEvent {
  final int id;  // Added ID to update specific note
  final String content;
  const SummarizeNoteEvent(this.id, this.content);

  @override
  List<Object> get props => [id, content];
}