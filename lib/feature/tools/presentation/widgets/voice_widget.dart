import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tools_bloc.dart';

class VoiceWidget extends StatefulWidget {
  const VoiceWidget({super.key});

  @override
  State<VoiceWidget> createState() => _VoiceWidgetState();
}

class _VoiceWidgetState extends State<VoiceWidget> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startVoiceToText() {
    context.read<ToolsBloc>().add(const VoiceToTextEvent());
  }

  void _startTextToVoice() {
    if (_textController.text.isNotEmpty) {
      context.read<ToolsBloc>().add(TextToVoiceEvent(_textController.text));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to convert to voice')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolsBloc, ToolsState>(
      builder: (context, state) {
        if (state is ToolsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ToolsVoiceToText) {
          _textController.text = state.text;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Voice to Text'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _startTextToVoice,
                  child: const Text('Convert to Voice'),
                ),
              ],
            ),
          );
        }
        if (state is ToolsTextToVoiceSuccess) {
          return const Center(child: Text('Voice conversion successful'));
        }
        if (state is ToolsError) {
          return Center(child: Text(state.message));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _startVoiceToText,
                child: const Text('Start Voice to Text'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Enter text for voice'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _startTextToVoice,
                child: const Text('Text to Voice'),
              ),
            ],
          ),
        );
      },
    );
  }
}