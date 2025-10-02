

import 'package:ai_productivity_super_app/feature/tasks/domain/entities/task_entity.dart';

import '../../../../share/services/database_service.dart';

class TasksLocalDataSource {
  Future<int> addTask(String title, {String? description, String? category, DateTime? deadline}) async {
    return await DatabaseService.instance.insertTask(title, description: description, category: category, deadline: deadline);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    return await DatabaseService.instance.getAllTasks();
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    return await DatabaseService.instance.getTaskById(id);
  }

  Future<int> updateTaskCategory(int id, String category) async {
    return await DatabaseService.instance.updateTaskCategory(id, category);
  }

  Future<int> updateTaskCompleted(int id, bool isCompleted) async {
    return await DatabaseService.instance.updateTaskCompleted(id, isCompleted);
  }
  Future<bool> deleteTask(int id) async {
    final db = await DatabaseService.instance.database;
    final result = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    return result > 0; // Returns true if deletion successful
  }
  Future<int> setTaskReminder(int id, DateTime? reminderTimestamp) async {
    return await DatabaseService.instance.setTaskReminder(id, reminderTimestamp);
  }
  Future<void> syncTasksFromFirestore(List<TaskEntity> tasks) async {
    // Implement local DB sync with Firestore data
    for (var task in tasks) {
      await DatabaseService.instance.upsertTask(task.toMap());
    }
  }
}