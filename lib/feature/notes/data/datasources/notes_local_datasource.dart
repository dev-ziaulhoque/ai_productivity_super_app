import 'package:ai_productivity_super_app/share/services/database_service.dart';

class NotesLocalDataSource {
  Future<int> addNote(String content) async {
    return await DatabaseService.instance.insertNote(content);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    return await DatabaseService.instance.getAllNotes();
  }

  Future<Map<String, dynamic>> getNoteById(int id) async {
    return await DatabaseService.instance.getNoteById(id);
  }

  Future<int> updateNoteSummary(int id, String summary) async {
    return await DatabaseService.instance.updateNoteSummary(id, summary);
  }
}