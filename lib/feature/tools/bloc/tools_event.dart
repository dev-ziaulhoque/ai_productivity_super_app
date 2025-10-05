part of 'tools_bloc.dart';

abstract class ToolsEvent extends Equatable {
  const ToolsEvent();

  @override
  List<Object> get props => [];
}

class GenerateImageEvent extends ToolsEvent {
  final String prompt;

  const GenerateImageEvent(this.prompt);

  @override
  List<Object> get props => [prompt];
}

class SummarizeDocEvent extends ToolsEvent {
  final String filePath;

  const SummarizeDocEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class VoiceToTextEvent extends ToolsEvent {
  const VoiceToTextEvent();

  @override
  List<Object> get props => [];
}

class TextToVoiceEvent extends ToolsEvent {
  final String text;

  const TextToVoiceEvent(this.text);

  @override
  List<Object> get props => [text];
}