import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/image_entity.dart';
import '../entities/doc_summary_entity.dart';

abstract class ToolsRepository {
  Future<Either<Failure, ImageEntity>> generateImage(String prompt);
  Future<Either<Failure, DocSummaryEntity>> summarizeDoc(String filePath);
  Future<Either<Failure, String>> voiceToText();
  Future<Either<Failure, void>> textToVoice(String text);
}