import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tools_bloc.dart';

class ImageGenWidget extends StatefulWidget {
  const ImageGenWidget({super.key});

  @override
  State<ImageGenWidget> createState() => _ImageGenWidgetState();
}

class _ImageGenWidgetState extends State<ImageGenWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolsBloc, ToolsState>(
      builder: (context, state) {
        if (state is ToolsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ToolsImageGenerated) {
          return Column(
            children: [
              Image.network(state.image.imageUrl),
              Text('Generated at: ${state.image.generatedAt}'),
              ElevatedButton(
                onPressed: () => context.read<ToolsBloc>().add(const GenerateImageEvent('')),
                child: const Text('New Image'),
              ),
            ],
          );
        }
        if (state is ToolsError) {
          return Center(child: Text(state.message));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Enter image prompt'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    context.read<ToolsBloc>().add(GenerateImageEvent(_controller.text));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prompt cannot be empty')),
                    );
                  }
                },
                child: const Text('Generate Image'),
              ),
            ],
          ),
        );
      },
    );
  }
}