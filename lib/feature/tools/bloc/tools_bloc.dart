import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../domain/entities/image_entity.dart';
import '../domain/entities/doc_summary_entity.dart';
import '../domain/usecases/generate_image_usecase.dart';
import '../domain/usecases/summarize_doc_usecase.dart';
import '../domain/usecases/usecase.dart';
import '../domain/usecases/voice_to_text_usecase.dart';
import '../domain/usecases/text_to_voice_usecase.dart';
import '../domain/repositories/tools_repository.dart';

part 'tools_event.dart';
part 'tools_state.dart';

class ToolsBloc extends HydratedBloc<ToolsEvent, ToolsState> {
  final ToolsRepository repository;
  late final GenerateImageUsecase _generateImageUsecase;
  late final SummarizeDocUsecase _summarizeDocUsecase;
  late final VoiceToTextUsecase _voiceToTextUsecase;
  late final TextToVoiceUsecase _textToVoiceUsecase;

  ToolsBloc(this.repository) : super(const ToolsInitial()) {
    _generateImageUsecase = GenerateImageUsecase(repository);
    _summarizeDocUsecase = SummarizeDocUsecase(repository);
    _voiceToTextUsecase = VoiceToTextUsecase(repository);
    _textToVoiceUsecase = TextToVoiceUsecase(repository);

    on<GenerateImageEvent>(_onGenerateImage);
    on<SummarizeDocEvent>(_onSummarizeDoc);
    on<VoiceToTextEvent>(_onVoiceToText);
    on<TextToVoiceEvent>(_onTextToVoice);
  }

  Future<void> _onGenerateImage(GenerateImageEvent event, Emitter<ToolsState> emit) async {
    if (event.prompt.isEmpty) {
      emit(const ToolsError('Prompt cannot be empty'));
      return;
    }
    emit(const ToolsLoading());
    final result = await _generateImageUsecase(GenerateImageParams(prompt: event.prompt));
    result.fold(
          (failure) => emit(ToolsError(failure.message)),
          (image) => emit(ToolsImageGenerated(image)),
    );
  }

  Future<void> _onSummarizeDoc(SummarizeDocEvent event, Emitter<ToolsState> emit) async {
    if (event.filePath.isEmpty) {
      emit(const ToolsError('File path cannot be empty'));
      return;
    }
    emit(const ToolsLoading());
    final result = await _summarizeDocUsecase(SummarizeDocParams(filePath: event.filePath));
    result.fold(
          (failure) => emit(ToolsError(failure.message)),
          (summary) => emit(ToolsDocSummarized(summary)),
    );
  }

  Future<void> _onVoiceToText(VoiceToTextEvent event, Emitter<ToolsState> emit) async {
    emit(const ToolsLoading());
    final result = await _voiceToTextUsecase(NoParams());
    result.fold(
          (failure) => emit(ToolsError(failure.message)),
          (text) => emit(ToolsVoiceToText(text)),
    );
  }

  Future<void> _onTextToVoice(TextToVoiceEvent event, Emitter<ToolsState> emit) async {
    if (event.text.isEmpty) {
      emit(const ToolsError('Text cannot be empty'));
      return;
    }
    emit(const ToolsLoading());
    final result = await _textToVoiceUsecase(TextToVoiceParams(text: event.text));
    result.fold(
          (failure) => emit(ToolsError(failure.message)),
          (_) => emit(const ToolsTextToVoiceSuccess()),
    );
  }

  @override
  ToolsState? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(ToolsState state) => null;
}