import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/streak_service.dart';
import '../../../core/constants/app_constants.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakService>(
      builder: (context, streakService, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Streak',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    // Settings button removed - only one settings button in main app bar
                  ],
                ),
                
                const Divider(),
                
                // Current and longest streak
                Row(
                  children: [
                    Expanded(
                      child: _buildStreakInfo(
                        context, 
                        'Current',
                        streakService.currentStreak.toString(),
                        streakService.currentStreak > 0,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Expanded(
                      child: _buildStreakInfo(
                        context, 
                        'Longest',
                        streakService.longestStreak.toString(),
                        true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Today's progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${streakService.getMinutesForToday()} / ${streakService.minimumMinutesPerDay} min',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      child: LinearProgressIndicator(
                        value: streakService.getTodayStreakProgress(),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        color: Theme.of(context).colorScheme.primary,
                        minHeight: 10,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status message
                    _buildStreakStatusMessage(context, streakService),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStreakInfo(
    BuildContext context, 
    String label, 
    String value,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.primary.withOpacity(0.3),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            Text(
              ' days',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStreakStatusMessage(BuildContext context, StreakService streakService) {
    final theme = Theme.of(context);
    
    if (streakService.isStreakMaintainedToday) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Great job! You\'ve reached your daily goal.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green,
            ),
          ),
        ],
      );
    }
    
    final missingMinutes = streakService.getMissingMinutesToday();
    if (streakService.currentStreak > 0) {
      return Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Focus for $missingMinutes more minutes to maintain your streak!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber[700],
            ),
          ),
        ],
      );
    }
    
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: theme.colorScheme.secondary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          'Complete $missingMinutes minutes today to start a streak!',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
  
  void _showStreakSettingsDialog(BuildContext context, StreakService streakService) {
    final currentMinutes = streakService.minimumMinutesPerDay;
    int selectedMinutes = currentMinutes;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Minimum Focus Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set the minimum number of minutes you need to focus each day to maintain your streak.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: selectedMinutes > 5
                              ? () => setState(() => selectedMinutes -= 5)
                              : null,
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            '$selectedMinutes minutes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: selectedMinutes < 120
                              ? () => setState(() => selectedMinutes += 5)
                              : null,
                        ),
                      ],
                    ),
                    Slider(
                      value: selectedMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$selectedMinutes min',
                      onChanged: (value) {
                        setState(() {
                          selectedMinutes = value.round();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              streakService.setMinimumMinutesPerDay(selectedMinutes);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}