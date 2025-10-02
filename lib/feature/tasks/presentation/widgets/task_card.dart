import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/tasks_bloc.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getColor(task.category ?? 'Personal'),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text('Category: ${task.category}\nReminder: ${task.reminderTimestamp?.toString() ?? 'None'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => context.read<TasksBloc>().add(CompleteTaskEvent(task.id!, value!)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => context.read<TasksBloc>().add(DeleteTaskEvent(task.id!)),
            ),
            IconButton(
              icon: const Icon(Icons.alarm, color: Colors.orange),
              onPressed: () => _showReminderDialog(context, task.id!),
            ),
          ],
        ),
        onTap: () => context.read<TasksBloc>().add(ClassifyTaskEvent(task.id!, task.title)),
      ),
    );
  }

  void _showReminderDialog(BuildContext context, int taskId) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) selectedDate = date;
              },
              child: Text('Select Date'),
            ),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) selectedTime = time;
              },
              child: Text('Select Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedDate != null && selectedTime != null) {
                final reminder = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                context.read<TasksBloc>().add(SetTaskReminderEvent(taskId, reminder));
              }
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
          TextButton(
            onPressed: () {
              context.read<TasksBloc>().add(SetTaskReminderEvent(taskId, null));
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.green;
      case 'Personal':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}