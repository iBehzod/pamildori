import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';
import 'task_item.dart';
import 'add_task_dialog.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final String emptyMessage;
  final bool showAddButtonOnEmpty;
  
  const TaskList({
    Key? key,
    required this.tasks,
    this.emptyMessage = 'No tasks yet',
    this.showAddButtonOnEmpty = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (showAddButtonOnEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ]
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onEdit: () => _showEditTaskDialog(context, task),
        );
      },
    );
  }
  
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }
  
  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(task: task),
    );
  }
} 