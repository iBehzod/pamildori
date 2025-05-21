import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';
import '../../../services/pomodoro_service.dart';
import '../../../core/utils/date_time_utils.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;
  
  const TaskItem({
    Key? key,
    required this.task,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final pomodoroService = Provider.of<PomodoroService>(context);
    final completedText = '${task.completedPomodoros}/${task.estimatedPomodoros}';
    final isCompleted = task.isCompleted;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.5), 
          width: 1
        ),
      ),
      child: InkWell(
        onTap: () => _onTaskTap(context, pomodoroService),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isCompleted, 
                  onChanged: (value) {
                    if (value != null) {
                      taskService.toggleTaskCompletion(task.id);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted 
                            ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    
                    if (task.description.isNotEmpty)
                      const SizedBox(height: 4),
                      
                    // Description
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer
                    Row(
                      children: [
                        // Pomodoro count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                completedText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Due date if available
                        if (task.dueDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDueDateColor(context, task.dueDate).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 14,
                                  color: _getDueDateColor(context, task.dueDate),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateTimeUtils.formatDateShort(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _getDueDateColor(context, task.dueDate),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) => _handleMenuSelection(context, value, taskService),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'focus',
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Focus on this'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(
                          isCompleted 
                              ? Icons.restart_alt_outlined 
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(isCompleted ? 'Mark as incomplete' : 'Mark as complete'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _onTaskTap(BuildContext context, PomodoroService pomodoroService) {
    // If task is completed, don't do anything
    if (task.isCompleted) return;
    
    // Check if pomodoro is already running
    if (pomodoroService.isRunning) {
      // Show dialog asking if user wants to switch tasks
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Switch Task?'),
          content: Text(
            'You are already focusing on "${pomodoroService.currentTask?.title ?? "a task"}". '
            'Do you want to switch to "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                pomodoroService.setCurrentTask(task);
              },
              child: const Text('Switch'),
            ),
          ],
        ),
      );
    } else {
      // Set current task and start timer if needed
      pomodoroService.setCurrentTask(task);
      
      // If timer is paused, show a snackbar suggesting to start
      if (pomodoroService.currentSession != null && 
          !pomodoroService.isRunning) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Now focusing on "${task.title}"'),
            action: SnackBarAction(
              label: 'Start Timer',
              onPressed: () {
                pomodoroService.startTimer();
              },
            ),
          ),
        );
      } else {
        // Let user know task was selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Now focusing on "${task.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _handleMenuSelection(
    BuildContext context, 
    String value, 
    TaskService taskService,
  ) {
    switch (value) {
      case 'edit':
        if (onEdit != null) {
          onEdit!();
        }
        break;
      case 'focus':
        final pomodoroService = Provider.of<PomodoroService>(context, listen: false);
        pomodoroService.setCurrentTask(task);
        
        // Navigate to timer tab
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(task.title),
              ),
              body: const Center(
                child: Text('Timer view will be implemented here'),
              ),
            ),
          ),
        );
        break;
      case 'complete':
        taskService.toggleTaskCompletion(task.id);
        break;
      case 'delete':
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  taskService.deleteTask(task.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
  
  Color _getDueDateColor(BuildContext context, DateTime? dueDate) {
    if (dueDate == null) return Colors.grey;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDateOnly.isBefore(today)) {
      // Overdue
      return Colors.red;
    } else if (dueDateOnly == today) {
      // Due today
      return Colors.orange;
    } else if (dueDateOnly == tomorrow) {
      // Due tomorrow
      return Colors.amber;
    } else {
      // Due in the future
      return Colors.green;
    }
  }
} 