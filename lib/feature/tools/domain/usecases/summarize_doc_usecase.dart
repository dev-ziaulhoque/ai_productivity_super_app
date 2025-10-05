import 'package:ai_productivity_super_app/feature/tools/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/doc_summary_entity.dart';
import '../repositories/tools_repository.dart';

class SummarizeDocUsecase extends UseCase<DocSummaryEntity, SummarizeDocParams> {
  final ToolsRepository repository;

  SummarizeDocUsecase(this.repository);

  @override
  Future<Either<Failure, DocSummaryEntity>> call(SummarizeDocParams params) async {
    return await repository.summarizeDoc(params.filePath);
  }
}

class SummarizeDocParams extends Equatable {
  final String filePath;

  const SummarizeDocParams({required this.filePath});

  @override
  List<Object> get props => [filePath];
}