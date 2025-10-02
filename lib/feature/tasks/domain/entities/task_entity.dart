import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final String? category; // Nullable, default "Personal" removed from constructor
  final DateTime? deadline;
  final bool isCompleted;
  final DateTime? reminderTimestamp;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.category = 'Personal', // Default value here
    this.deadline,
    this.isCompleted = false,
    this.reminderTimestamp,
  });

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String?, // Nullable
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline'] as String) : null,
      isCompleted: (map['is_completed'] as int?) == 1,
      reminderTimestamp: map['reminder_timestamp'] != null ? DateTime.tryParse(map['reminder_timestamp'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category, // Ensure category is included
      'deadline': deadline?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'reminder_timestamp': reminderTimestamp?.toIso8601String(),
    };
  }

  TaskEntity copyWith({String? category, bool? isCompleted, DateTime? reminderTimestamp}) {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      category: category ?? this.category,
      deadline: deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTimestamp: reminderTimestamp ?? this.reminderTimestamp,
    );
  }

  @override
  List<Object?> get props => [id, title, description, category, deadline, isCompleted, reminderTimestamp];
}