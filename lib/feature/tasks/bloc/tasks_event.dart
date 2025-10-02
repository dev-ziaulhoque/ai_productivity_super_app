part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TasksEvent {
  const LoadTasksEvent();
}

class AddTaskEvent extends TasksEvent {
  final String title;
  final String? description;
  final DateTime? deadline;

  const AddTaskEvent(this.title, {this.description, this.deadline});

  @override
  List<Object?> get props => [title, description, deadline];
}

class ClassifyTaskEvent extends TasksEvent {
  final int id;
  final String text;

  const ClassifyTaskEvent(this.id, this.text);

  @override
  List<Object> get props => [id, text];
}

class CompleteTaskEvent extends TasksEvent {
  final int id;
  final bool isCompleted;

  const CompleteTaskEvent(this.id, this.isCompleted);

  @override
  List<Object> get props => [id, isCompleted];
}
class DeleteTaskEvent extends TasksEvent { // New
  final int id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object> get props => [id];
}
class SetTaskReminderEvent extends TasksEvent {
  final int id;
  final DateTime? reminderTimestamp;

  const SetTaskReminderEvent(this.id, this.reminderTimestamp);

  @override
  List<Object?> get props => [id, reminderTimestamp];
}