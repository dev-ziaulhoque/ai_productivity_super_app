import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import '../../../../core/error/exceptions.dart';

class ToolsRemoteDataSource {
  final Dio _dio = Dio();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _lastRecognizedText = '';
  final Logger _logger = Logger();

  Future<String> generateImage(String prompt) async {
    final token = dotenv.env['HF_TOKEN'];
    if (token == null) {
      _logger.e('Hugging Face token not found');
      throw ServerException('Hugging Face token not found');
    }
    _dio.options.baseUrl = 'https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5';
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      _logger.i('Generating image with prompt: $prompt');
      final response = await _dio.post('/v1/generation', data: {'inputs': prompt}); // Corrected endpoint
      _logger.d('API Response: ${response.data}');
      if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
        final imageData = response.data[0]['generated_image'] as String?; // Updated key
        if (imageData != null) {
          _logger.i('Image generated successfully');
          return imageData; // Base64 image
        } else {
          _logger.e('Image data is null in API response');
          throw ServerException('No image data received from API');
        }
      } else if (response.statusCode == 404) {
        _logger.e('API endpoint not found: Status 404');
        throw ServerException('API endpoint not found. Check configuration.');
      } else {
        _logger.e('Invalid API response: Status ${response.statusCode}, Data ${response.data}');
        throw ServerException('Invalid response from API');
      }
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw ServerException('Failed to generate image: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw ServerException('Failed to generate image: $e');
    }
  }

  Future<String> summarizeDoc(String filePath) async {
    if (!File(filePath).existsSync()) {
      _logger.e('File not found: $filePath');
      throw ServerException('File not found');
    }
    try {
      final loadDocument = PdfDocument(inputBytes: File(filePath).readAsBytesSync());
      final textExtractor = PdfTextExtractor(loadDocument);
      String text = '';
      for (var i = 0; i < loadDocument.pages.count; i++) {
        final pageText = textExtractor.extractText(startPageIndex: i, endPageIndex: i);
        text += pageText ?? '';
      }
      loadDocument.dispose();
      if (text.isEmpty) {
        _logger.e('No text extracted from file: $filePath');
        throw ServerException('No text extracted from file');
      }
      _logger.i('Text extracted successfully from $filePath');
      return 'Summary: ${text.substring(0, text.length > 100 ? 100 : text.length)}...';
    } catch (e) {
      _logger.e('Failed to extract text from PDF: $e');
      throw ServerException('Failed to extract text from PDF: $e');
    }
  }

  Future<String> voiceToText() async {
    try {
      // Check and request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _logger.e('Microphone permission denied');
        throw ServerException('Microphone permission required');
      }
      if (!await _speechToText.initialize()) {
        _logger.e('Speech recognition not available');
        throw ServerException('Speech recognition not available');
      }
      final isListening = await _speechToText.listen(onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _lastRecognizedText = result.recognizedWords;
        }
      });
      if (isListening == null || !isListening) {
        _logger.e('Failed to start listening');
        throw ServerException('Failed to start listening');
      }
      await Future.delayed(const Duration(seconds: 5)); // Simulate listening
      await _speechToText.stop();
      final result = _lastRecognizedText.isNotEmpty ? _lastRecognizedText : 'No voice detected';
      _logger.i('Voice to text result: $result');
      _lastRecognizedText = ''; // Reset
      return result;
    } catch (e) {
      _logger.e('Failed to convert voice to text: $e');
      throw ServerException('Failed to convert voice to text: $e');
    }
  }

  Future<void> textToVoice(String text) async {
    if (text.isEmpty) {
      _logger.e('Text cannot be empty');
      throw ServerException('Text cannot be empty');
    }
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
      _logger.i('Text to voice completed: $text');
    } catch (e) {
      _logger.e('Failed to convert text to voice: $e');
      throw ServerException('Failed to convert text to voice: $e');
    }
  }
}