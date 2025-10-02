import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final int? id;
  final String content;
  final String? summary;
  final DateTime? createdAt;

  const NoteEntity({
    this.id,
    required this.content,
    this.summary,
    this.createdAt,
  });

  factory NoteEntity.fromMap(Map<String, dynamic> map) {
    return NoteEntity(
      id: map['id'] as int?,
      content: map['content'] as String,
      summary: map['summary'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'summary': summary,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  NoteEntity copyWith({String? summary}) {
    return NoteEntity(
      id: id,
      content: content,
      createdAt: createdAt,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [id, content, summary, createdAt];
}