import 'package:ai_productivity_super_app/feature/tools/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tools_repository.dart';

class TextToVoiceUsecase extends UseCase<void, TextToVoiceParams> {
  final ToolsRepository repository;

  TextToVoiceUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(TextToVoiceParams params) async {
    return await repository.textToVoice(params.text);
  }
}

class TextToVoiceParams extends Equatable {
  final String text;

  const TextToVoiceParams({required this.text});

  @override
  List<Object> get props => [text];
}