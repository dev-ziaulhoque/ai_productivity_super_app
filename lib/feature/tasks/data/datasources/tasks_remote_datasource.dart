import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class TasksRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  TasksRemoteDataSource() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api-inference.huggingface.co/models/facebook/bart-large-mnli',
    headers: {'Authorization': 'Bearer ${dotenv.env['HF_TOKEN']}'},
  ));

  Future<String> classifyTask(String text) async {
    try {
      final requestBody = {
        'inputs': text,
        'parameters': {
          'candidate_labels': ['Work', 'Study', 'Personal'],
        },
      };
      final response = await _dio.post('', data: requestBody);
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('labels') && data.containsKey('scores')) {
        final labels = data['labels'] as List<dynamic>;
        final scores = data['scores'] as List<dynamic>;
        if (labels.isNotEmpty && scores.isNotEmpty) {
          int maxIndex = 0;
          double maxScore = scores[0];
          for (int i = 1; i < scores.length; i++) {
            if (scores[i] > maxScore) {
              maxScore = scores[i];
              maxIndex = i;
            }
          }
          return labels[maxIndex] as String; // Highest score category
        }
      }
      _logger.w('Invalid classification response: ${response.data}');
      return 'Personal'; // Fallback
    } catch (e) {
      _logger.e('Classification error: $e');
      return 'Personal'; // Fallback on error
    }
  }
}