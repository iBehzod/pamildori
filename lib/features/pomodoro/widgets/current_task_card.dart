import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/task_model.dart';

class CurrentTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onRemove;
  
  const CurrentTaskCard({
    super.key,
    required this.task,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Task',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                // Remove task button
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove current task',
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            
            const Divider(),
            
            // Task title
            Text(
              task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              // Task description
              Text(
                task.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Progress indicator
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pomodoros: ${task.completedPomodoros}/${task.estimatedPomodoros}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              child: LinearProgressIndicator(
                value: task.progress,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}