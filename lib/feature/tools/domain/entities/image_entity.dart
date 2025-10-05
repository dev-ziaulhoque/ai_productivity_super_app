import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final String imageUrl;
  final DateTime generatedAt;

  const ImageEntity({required this.imageUrl, required this.generatedAt});

  @override
  List<Object> get props => [imageUrl, generatedAt];
}