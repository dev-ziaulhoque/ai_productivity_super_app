import 'package:ai_productivity_super_app/feature/tools/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/image_entity.dart';
import '../repositories/tools_repository.dart';

class GenerateImageUsecase extends UseCase<ImageEntity, GenerateImageParams> {
  final ToolsRepository repository;

  GenerateImageUsecase(this.repository);

  @override
  Future<Either<Failure, ImageEntity>> call(GenerateImageParams params) async {
    return await repository.generateImage(params.prompt);
  }
}

class GenerateImageParams extends Equatable {
  final String prompt;

  const GenerateImageParams({required this.prompt});

  @override
  List<Object> get props => [prompt];
}