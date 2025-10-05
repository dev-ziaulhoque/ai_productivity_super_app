import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/doc_summary_entity.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/repositories/tools_repository.dart';
import '../datasources/tools_remote_datasource.dart';

class ToolsRepositoryImpl implements ToolsRepository {
  final ToolsRemoteDataSource remoteDataSource;

  ToolsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ImageEntity>> generateImage(String prompt) async {
    try {
      final imageUrl = await remoteDataSource.generateImage(prompt);
      return Right(ImageEntity(imageUrl: imageUrl, generatedAt: DateTime.now()));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DocSummaryEntity>> summarizeDoc(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final summary = await remoteDataSource.summarizeDoc(filePath);
      return Right(DocSummaryEntity(
        summary: summary,
        originalFileName: fileName,
        summarizedAt: DateTime.now(),
      ));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> voiceToText() async {
    try {
      final text = await remoteDataSource.voiceToText();
      return Right(text.isNotEmpty ? text : 'No voice detected');
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> textToVoice(String text) async {
    try {
      if (text.isNotEmpty) {
        await remoteDataSource.textToVoice(text);
        return const Right(null);
      }
      return Left(ValidationFailure('Text cannot be empty'));
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}