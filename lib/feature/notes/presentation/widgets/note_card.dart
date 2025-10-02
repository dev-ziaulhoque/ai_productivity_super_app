import 'package:flutter/material.dart';
import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback? onSummarize;

  const NoteCard({super.key, required this.note, this.onSummarize});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content, style: const TextStyle(fontSize: 16)),
            if (note.summary != null && note.summary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Summary: ${note.summary}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            if (onSummarize != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.summarize),
                  onPressed: onSummarize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}