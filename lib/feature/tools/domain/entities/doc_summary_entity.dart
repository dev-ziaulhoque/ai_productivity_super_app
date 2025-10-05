import 'package:equatable/equatable.dart';

class DocSummaryEntity extends Equatable {
  final String summary;
  final String originalFileName;
  final DateTime summarizedAt;

  const DocSummaryEntity({
    required this.summary,
    required this.originalFileName,
    required this.summarizedAt,
  });

  @override
  List<Object> get props => [summary, originalFileName, summarizedAt];
}