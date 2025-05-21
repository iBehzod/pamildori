import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../constants/app_constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool> onCompletionToggle;
  
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCompletionToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) => onCompletionToggle(value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted 
                            ? theme.textTheme.titleMedium?.color?.withOpacity(0.5)
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingSmall / 2),
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        _buildPomodoroIndicator(
                          theme, 
                          task.completedPomodoros,
                          task.estimatedPomodoros,
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        if (task.deadline != null) ...[
                          _buildDeadlineIndicator(theme, task.deadline!),
                        ],
                        const Spacer(),
                        _buildPriorityIndicator(theme, task.priority),
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildTagsList(theme, task.tags),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPomodoroIndicator(ThemeData theme, int completed, int estimated) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: AppConstants.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$completed/$estimated',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeadlineIndicator(ThemeData theme, DateTime deadline) {
    final now = DateTime.now();
    final isOverdue = deadline.isBefore(now);
    final color = isOverdue ? theme.colorScheme.error : theme.colorScheme.secondary;
    
    // Format date to show only relevant info
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    String dateText;
    if (deadlineDate == today) {
      dateText = 'Today';
    } else if (deadlineDate == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      final diff = deadlineDate.difference(today).inDays;
      if (diff < 7) {
        final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][deadline.weekday - 1];
        dateText = weekday;
      } else {
        dateText = '${deadline.day}/${deadline.month}';
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: AppConstants.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriorityIndicator(ThemeData theme, int priority) {
    Color getColorForPriority(int p) {
      switch (p) {
        case 1:
          return Colors.red;
        case 2:
          return Colors.orange;
        case 3:
          return Colors.yellow;
        case 4:
          return Colors.blue;
        case 5:
        default:
          return Colors.grey;
      }
    }
    
    String getPriorityLabel(int p) {
      switch (p) {
        case 1:
          return 'High';
        case 2:
          return 'Medium-High';
        case 3:
          return 'Medium';
        case 4:
          return 'Medium-Low';
        case 5:
        default:
          return 'Low';
      }
    }
    
    final color = getColorForPriority(priority);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          getPriorityLabel(priority),
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTagsList(ThemeData theme, List<String> tags) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingXSmall,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.secondary,
            ),
          ),
        );
      }).toList(),
    );
  }
}