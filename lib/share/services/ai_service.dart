import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../feature/notes/data/datasources/notes_local_datasource.dart';

class AiService {
  final Dio _dio;
  final Logger _logger = Logger();
  final NotesLocalDataSource _localDataSource;

  AiService({NotesLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? NotesLocalDataSource(),
        _dio = Dio(BaseOptions(
          baseUrl: 'https://api-inference.huggingface.co/models/sshleifer/distilbart-cnn-12-6',
          headers: {'Authorization': 'Bearer ${dotenv.env['HF_TOKEN']}'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('API Request: ${options.method} ${options.uri}\nData: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('API Response: ${response.statusCode}\nData: ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        _logger.e('API Error: ${e.response?.statusCode} ${e.message}\nResponse: ${e.response?.data}');
        if (e.response?.statusCode == 429) {
          _logger.w('Rate limit hit, retrying after 5s');
          Future.delayed(const Duration(seconds: 5), () => handler.resolve(e.response!));
        } else {
          handler.next(e);
        }
      },
    ));
  }

  Future<String> summarizeText(String text, int noteId) async {
    try {
      // Check cache first
      final cachedNote = await _localDataSource.getNoteById(noteId);
      if (cachedNote['summary'] != null && cachedNote['summary'].isNotEmpty) {
        final cachedSummary = cachedNote['summary'] as String;
        if (cachedSummary.length > 20 && !cachedSummary.contains('dfhf')) { // Basic validation
          _logger.d('Returning cached summary for note $noteId: $cachedSummary');
          return cachedSummary;
        } else {
          _logger.w('Cached summary invalid, forcing API call for note $noteId');
        }
      }

      if (text.isEmpty) {
        _logger.e('Error: Empty input text');
        throw ServerException('Input text cannot be empty');
      }

      final requestBody = {
        'inputs': text,
        'parameters': {
          'max_length': 130,
          'min_length': 30,
          'do_sample': false,
        }
      };

      final response = await _dio.post('', data: requestBody);
      if (response.data is List && response.data.isNotEmpty) {
        final summary = response.data[0]['summary_text'] as String;
        _logger.d('Cached summary for note $noteId: $summary');
        await _localDataSource.updateNoteSummary(noteId, summary);
        return summary;
      } else {
        _logger.e('Invalid response format: ${response.data}');
        throw ServerException('Invalid response format');
      }
    } on DioException catch (e) {
      final message = e.response?.statusCode == 400
          ? 'Invalid request format (check input)'
          : e.response?.statusCode == 401
          ? 'Invalid API token'
          : e.response?.statusCode == 429
          ? 'API rate limit exceeded, try again later'
          : e.message ?? 'API error';
      _logger.e('DioException: $message');
      throw ServerException(message);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }
}