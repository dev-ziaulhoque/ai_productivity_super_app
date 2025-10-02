import 'package:ai_productivity_super_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logger/logger.dart';
import '../../../share/services/notification_service.dart';
import '../domain/entities/task_entity.dart';
import '../domain/usecases/add_task_usecase.dart';
import '../domain/usecases/classify_task_usecase.dart';
import '../domain/usecases/delete_task_usecase.dart';
import '../domain/usecases/update_task_category_usecase.dart';
import '../domain/usecases/update_task_completed_usecase.dart';
import '../domain/usecases/set_task_reminder_usecase.dart';
import '../domain/repositories/tasks_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends HydratedBloc<TasksEvent, TasksState> {
  final TasksRepository repository;
  late final AddTaskUsecase _addTaskUsecase;
  late final ClassifyTaskUsecase _classifyTaskUsecase;
  late final UpdateTaskCategoryUsecase _updateTaskCategoryUsecase;
  late final UpdateTaskCompletedUsecase _updateTaskCompletedUsecase;
  late final DeleteTaskUsecase _deleteTaskUsecase;
  late final SetTaskReminderUsecase _setTaskReminderUsecase;
  final _logger = Logger();
  final NotificationService _notificationService = NotificationService();

  TasksBloc(this.repository) : super(const TasksInitial()) {
    _addTaskUsecase = AddTaskUsecase(repository);
    _classifyTaskUsecase = ClassifyTaskUsecase(repository);
    _updateTaskCategoryUsecase = UpdateTaskCategoryUsecase(repository);
    _updateTaskCompletedUsecase = UpdateTaskCompletedUsecase(repository);
    _deleteTaskUsecase = DeleteTaskUsecase(repository);
    _setTaskReminderUsecase = SetTaskReminderUsecase(repository);

    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<ClassifyTaskEvent>(_onClassifyTask);
    on<CompleteTaskEvent>(_onCompleteTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<SetTaskReminderEvent>(_onSetTaskReminder);

    // Initialize notification service when bloc starts
    _notificationService.initialize();
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TasksState> emit) async {
    _logger.i('Loading tasks... Current state: $state');
    emit( TasksLoading());
    final result = await repository.getAllTasks();
    result.fold(
          (failure) {
        _logger.e('Failed to load tasks: ${failure.message}');
        emit(TasksError(failure.message));
      },
          (tasks) {
        _logger.i('Tasks loaded successfully: ${tasks.length} tasks');
        emit(TasksLoaded(tasks));
      },
    );
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TasksState> emit) async {
    _logger.i('Adding task: ${event.title}, Current state: $state');
    List<TaskEntity> previousTasks = [];
    if (state is TasksLoaded) {
      previousTasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    }

    emit( TasksLoading());
    final result = await _addTaskUsecase(event.title, description: event.description, deadline: event.deadline);
    result.fold(
          (failure) {
        _logger.e('Failed to add task: ${failure.message}');
        emit(TasksError(failure.message));
      },
          (task) {
        _logger.i('Task added successfully: ${task.title}');
        previousTasks.add(task);
        emit(TasksLoaded(previousTasks));
      },
    );
  }

  Future<void> _onClassifyTask(ClassifyTaskEvent event, Emitter<TasksState> emit) async {
    _logger.i('Classifying task with ID: ${event.id}, Text: ${event.text}, Current state: $state');
    List<TaskEntity> previousTasks = [];
    if (state is TasksLoaded) {
      previousTasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    } else {
      _logger.e('Classify called in invalid state: ${state.runtimeType}');
      emit(TasksError('Cannot classify in current state'));
      return;
    }

    emit( TasksLoading());

    try {
      final classifyResult = await _classifyTaskUsecase(event.text).timeout(
        const Duration(seconds: 30),
        onTimeout: () => Left(ServerFailure('Classification timed out')),
      );
      final category = await classifyResult.fold(
            (failure) {
          _logger.e('Classification failed: ${failure.message}');
          return Future.value('Personal');
        },
            (category) => Future.value(category),
      );
      final updateResult = await _updateTaskCategoryUsecase(event.id, category);
      updateResult.fold(
            (failure) {
          _logger.e('Update category failed: ${failure.message}');
          emit(TasksError(failure.message));
        },
            (updatedTask) {
          final index = previousTasks.indexWhere((t) => t.id == event.id);
          if (index != -1) {
            previousTasks[index] = updatedTask;
            emit(TasksLoaded(previousTasks));
          } else {
            emit(TasksError('Task not found'));
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during classification: $e');
      emit(TasksError('Unexpected error: $e'));
    }
  }

  Future<void> _onCompleteTask(CompleteTaskEvent event, Emitter<TasksState> emit) async {
    _logger.i('Completing task with ID: ${event.id}, IsCompleted: ${event.isCompleted}, Current state: $state');
    List<TaskEntity> previousTasks = [];
    if (state is TasksLoaded) {
      previousTasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    } else {
      _logger.e('Complete called in invalid state: ${state.runtimeType}');
      emit(TasksError('Cannot complete in current state'));
      return;
    }

    emit( TasksLoading());

    final result = await _updateTaskCompletedUsecase(event.id, event.isCompleted);
    result.fold(
          (failure) {
        _logger.e('Failed to complete task: ${failure.message}');
        emit(TasksError(failure.message));
      },
          (updatedTask) {
        final index = previousTasks.indexWhere((t) => t.id == event.id);
        if (index != -1) {
          previousTasks[index] = updatedTask;
          emit(TasksLoaded(previousTasks));
        } else {
          emit(TasksError('Task not found'));
        }
      },
    );
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TasksState> emit) async {
    _logger.i('Deleting task with ID: ${event.id}, Current state: $state');
    List<TaskEntity> previousTasks = [];
    if (state is TasksLoaded) {
      previousTasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    } else {
      _logger.e('Delete called in invalid state: ${state.runtimeType}');
      emit(TasksError('Cannot delete in current state'));
      return;
    }

    emit( TasksLoading());
    _logger.i('Deleting task in progress...');

    final result = await _deleteTaskUsecase(event.id);
    result.fold(
          (failure) {
        _logger.e('Failed to delete task: ${failure.message}');
        emit(TasksError(failure.message));
      },
          (success) {
        if (success) {
          _logger.i('Task deleted successfully with ID: ${event.id}');
          previousTasks.removeWhere((t) => t.id == event.id);
          emit(TasksLoaded(previousTasks));
        } else {
          _logger.e('Task not found or deletion failed for ID: ${event.id}');
          emit(TasksError('Task deletion failed'));
        }
      },
    );
  }

  Future<void> _onSetTaskReminder(SetTaskReminderEvent event, Emitter<TasksState> emit) async {
    _logger.i('Setting reminder for task ID: ${event.id}, Time: ${event.reminderTimestamp}, Current state: $state');
    List<TaskEntity> previousTasks = [];
    if (state is TasksLoaded) {
      previousTasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    } else {
      _logger.e('Set reminder called in invalid state: ${state.runtimeType}');
      emit(TasksError('Cannot set reminder in current state'));
      return;
    }

    emit( TasksLoading());
    _logger.i('Setting reminder in progress...');

    final result = await _setTaskReminderUsecase(event.id, event.reminderTimestamp);
    result.fold(
          (failure) {
        _logger.e('Failed to set reminder: ${failure.message}');
        emit(TasksError(failure.message));
      },
          (updatedTask) {
        _logger.i('Reminder set successfully for task ID: ${event.id}');
        final index = previousTasks.indexWhere((t) => t.id == event.id);
        if (index != -1) {
          previousTasks[index] = updatedTask;
          // Schedule or cancel notification
          if (updatedTask.reminderTimestamp != null) {
            final now = DateTime.now();
            if (updatedTask.reminderTimestamp!.isAfter(now)) {
              _notificationService.scheduleNotification(
                updatedTask.id!,
                'Task Reminder',
                'Time to work on: ${updatedTask.title}',
                updatedTask.reminderTimestamp!,
              );
              _logger.i('Notification scheduled for task ID: ${updatedTask.id} at ${updatedTask.reminderTimestamp}');
            } else {
              _logger.w('Reminder time (${updatedTask.reminderTimestamp}) is in the past, skipping notification.');
            }
          } else {
            _notificationService.cancelNotification(updatedTask.id!);
            _logger.i('Notification cancelled for task ID: ${updatedTask.id}');
          }
          emit(TasksLoaded(previousTasks));
        } else {
          emit(TasksError('Task not found'));
        }
      },
    );
  }

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  TasksState? fromJson(Map<String, dynamic> json) {
    try {
      return TasksLoaded(
        (json['tasks'] as List).map((map) => TaskEntity.fromMap(map as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      _logger.e('Error parsing JSON: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TasksState state) {
    if (state is TasksLoaded) {
      return {'tasks': state.tasks.map((task) => task.toMap()).toList()};
    }
    return null;
  }
}