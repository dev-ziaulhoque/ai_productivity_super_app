import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tools_bloc.dart';

class DocHelperWidget extends StatefulWidget {
  const DocHelperWidget({super.key});

  @override
  State<DocHelperWidget> createState() => _DocHelperWidgetState();
}

class _DocHelperWidgetState extends State<DocHelperWidget> {
  String? _filePath;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.single.path;
      });
      if (_filePath != null) {
        context.read<ToolsBloc>().add(SummarizeDocEvent(_filePath!));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid file selected')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolsBloc, ToolsState>(
      builder: (context, state) {
        if (state is ToolsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ToolsDocSummarized) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: ${state.summary.originalFileName}'),
                const SizedBox(height: 10),
                Text('Summary: ${state.summary.summary}'),
                Text('Summarized at: ${state.summary.summarizedAt}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Upload New File'),
                ),
              ],
            ),
          );
        }
        if (state is ToolsError) {
          return Center(child: Text(state.message));
        }
        return Center(
          child: ElevatedButton(
            onPressed: _pickFile,
            child: const Text('Upload PDF/DOC File'),
          ),
        );
      },
    );
  }
}