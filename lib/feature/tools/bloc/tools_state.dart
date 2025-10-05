part of 'tools_bloc.dart';

abstract class ToolsState extends Equatable {
  const ToolsState();

  @override
  List<Object> get props => [];
}

class ToolsInitial extends ToolsState {
  const ToolsInitial();
}

class ToolsLoading extends ToolsState {
  const ToolsLoading();
}

class ToolsImageGenerated extends ToolsState {
  final ImageEntity image;

  const ToolsImageGenerated(this.image);

  @override
  List<Object> get props => [image];
}

class ToolsDocSummarized extends ToolsState {
  final DocSummaryEntity summary;

  const ToolsDocSummarized(this.summary);

  @override
  List<Object> get props => [summary];
}

class ToolsVoiceToText extends ToolsState {
  final String text;

  const ToolsVoiceToText(this.text);

  @override
  List<Object> get props => [text];
}

class ToolsTextToVoiceSuccess extends ToolsState {
  const ToolsTextToVoiceSuccess();
}

class ToolsError extends ToolsState {
  final String message;

  const ToolsError(this.message);

  @override
  List<Object> get props => [message];
}