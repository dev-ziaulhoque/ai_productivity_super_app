import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ChatService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api-inference.huggingface.co/models/distilbert/distilgpt2'; // Updated to correct model
  static final String? _token = dotenv.env['HF_TOKEN'];

  Future<String> getChatResponse(String message) async {
    if (_token == null) {
      throw Exception('HF Token not found in .env');
    }

    _dio.options.headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };

    try {
      print('Sending request to: $_baseUrl with message: $message'); // Debug log
      final response = await _dio.post(
        _baseUrl,
        data: jsonEncode({
          'inputs': message,
          'parameters': {
            'max_length': 100,
            'temperature': 0.7,
          },
          'options': {'wait_for_model': true}, // Wait for model to load
        }),
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Allow 400-level for debugging
          },
        ),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response data: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>? ?? {};
        final generatedText = data['generated_text'] as String? ?? data['choices']?[0]['text'] as String? ?? 'No response';
        print('Chat Response: $generatedText'); // Print response
        return generatedText;
      } else {
        print('API Error: ${response.statusCode} - ${response.data}');
        throw Exception('API error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('DioException: $e'); // Print full exception
      throw Exception('DioException: $e');
    }
  }
}