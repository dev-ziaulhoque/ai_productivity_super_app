import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notes_bloc.dart';
import '../widgets/note_card.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        body: BlocConsumer<NotesBloc, NotesState>(
          listener: (context, state) {
            if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotesLoaded) {
              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return NoteCard(
                    note: note,
                    onSummarize: () => context.read<NotesBloc>().add(SummarizeNoteEvent(note.id!, note.content)),
                  );
                },
              );
            } else if (state is NotesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No notes yet. Add one!'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddNoteDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter note content'),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<NotesBloc>().add(AddNoteEvent(controller.text));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}