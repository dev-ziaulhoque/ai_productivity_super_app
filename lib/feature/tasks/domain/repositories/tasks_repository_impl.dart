import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/tasks_local_datasource.dart';
import '../../data/datasources/tasks_remote_datasource.dart';
import '../entities/task_entity.dart';
import '../repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksLocalDataSource localDataSource;
  final TasksRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TasksRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<Either<Failure, TaskEntity>> addTask(String title, {String? description, String? category, DateTime? deadline}) async {
    try {
      final id = await localDataSource.addTask(title, description: description, category: category, deadline: deadline);
      final localMap = await localDataSource.getTaskById(id);
      final task = TaskEntity.fromMap(localMap);
      print('Syncing to Firestore: ${task.toMap()}'); // Debug log
      await firestore.collection('tasks').doc(task.id.toString()).set(task.toMap());
      // Return the task directly after Firestore sync
      final updatedDoc = await firestore.collection('tasks').doc(task.id.toString()).get();
      return Right(TaskEntity.fromMap(updatedDoc.data()!));
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks() async {
    try {
      final snapshot = await firestore.collection('tasks').get();
      final firestoreTasks = snapshot.docs.map((doc) => TaskEntity.fromMap(doc.data())).toList();
      print('Firestore tasks: $firestoreTasks'); // Debug log
      await localDataSource.syncTasksFromFirestore(firestoreTasks); // Sync Firestore to local
      return Right(firestoreTasks); // Return Firestore data
    } on Exception {
      // Fallback to local data if Firestore fails
      final localMaps = await localDataSource.getAllTasks();
      final localTasks = localMaps.map(TaskEntity.fromMap).toList();
      return Right(localTasks);
    }
  }

  @override
  Future<Either<Failure, String>> classifyTask(String text) async {
    try {
      final category = await remoteDataSource.classifyTask(text);
      return Right(category);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTaskCategory(int id, String category) async {
    try {
      await localDataSource.updateTaskCategory(id, category);
      final map = await localDataSource.getTaskById(id);
      final task = TaskEntity.fromMap(map);
      await firestore.collection('tasks').doc(id.toString()).update(task.toMap());
      return Right(task);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTaskCompleted(int id, bool isCompleted) async {
    try {
      await localDataSource.updateTaskCompleted(id, isCompleted);
      final map = await localDataSource.getTaskById(id);
      final task = TaskEntity.fromMap(map);
      await firestore.collection('tasks').doc(id.toString()).update(task.toMap());
      return Right(task);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(int id) async {
    try {
      final deleted = await localDataSource.deleteTask(id);
      if (deleted) {
        await firestore.collection('tasks').doc(id.toString()).delete();
      }
      return Right(deleted);
    } on Exception {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> setTaskReminder(int id, DateTime? reminderTimestamp) async {
    try {
      await localDataSource.setTaskReminder(id, reminderTimestamp);
      final map = await localDataSource.getTaskById(id);
      final task = TaskEntity.fromMap(map);
      await firestore.collection('tasks').doc(id.toString()).update(task.toMap());
      return Right(task);
    } on Exception {
      return Left(ServerFailure('Failed to set reminder'));
    }
  }
}