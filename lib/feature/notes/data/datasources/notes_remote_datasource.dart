import 'package:ai_productivity_super_app/share/services/ai_service.dart';


class NotesRemoteDataSource {
  final AiService _aiService;

  NotesRemoteDataSource({AiService? aiService}) : _aiService = aiService ?? AiService();

  Future<String> summarizeNote(String content, int noteId) async {
    return await _aiService.summarizeText(content, noteId); // Pass noteId
  }
}