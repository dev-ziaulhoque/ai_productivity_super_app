import 'package:ai_productivity_super_app/feature/tools/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/tools_repository.dart';

class VoiceToTextUsecase extends UseCase<String, NoParams> {
  final ToolsRepository repository;

  VoiceToTextUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.voiceToText();
  }
}