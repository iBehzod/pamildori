import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pomodoro_utils.dart';
import '../../../core/widgets/circular_timer.dart';
import '../../../models/pomodoro_model.dart';
import '../../../models/task_model.dart'; // Add import for Task
import '../../../services/pomodoro_service.dart';
import '../../../services/task_service.dart';
import '../../settings/screens/settings_screen.dart';
import '../../statistics/screens/statistics_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../tasks/widgets/add_task_dialog.dart'; // Fixed import path
import '../widgets/timer_control_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 1; // Start with timer tab selected
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: _currentIndex,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pamildori'),
        actions: [
          // Only show settings button on the Timer tab (index 1)
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          TasksScreen(),
          TimerTab(),
          StatisticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}

class TimerTab extends StatelessWidget {
  const TimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroService>(
      builder: (context, pomodoroService, _) {
        return Consumer<TaskService>(
          builder: (context, taskService, _) {
            final currentSession = pomodoroService.currentSession;
            final isRunning = pomodoroService.isRunning;
            final theme = Theme.of(context);
            final activeTasks = taskService.activeTasks;

            // Check if waiting for continue decision and show dialog
            if (pomodoroService.isWaitingForContinueDecision) {
              // Show dialog after a short delay to ensure the UI is built
              Future.delayed(Duration.zero, () {
                _showContinueDialog(context, pomodoroService);
              });
            }

            // Default to work timer if no session is active
            final sessionType = currentSession?.type ?? PomodoroType.work;
            final sessionColor = PomodoroUtils.getColorForSessionType(sessionType, theme);
            final sessionName = PomodoroUtils.getNameForSessionType(sessionType);

            return Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Session type indicator
                      Text(
                        sessionName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: sessionColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Current task - improved with selection capability
                      InkWell(
                        onTap: () => _showTaskSelector(context, taskService, pomodoroService),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                pomodoroService.currentTask != null
                                    ? Icons.check_circle_outline
                                    : Icons.add_task,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pomodoroService.currentTask?.title ?? 'Select a task',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Timer
                      CircularTimer(
                        progress: currentSession != null
                            ? PomodoroUtils.calculateProgress(currentSession)
                            : 0,
                        timeText: currentSession != null
                            ? PomodoroUtils.formatTime(currentSession.remainingSeconds)
                            : PomodoroUtils.formatTime(
                                pomodoroService.settings.workDurationMinutes * 60),
                        color: sessionColor,
                        size: 280, // Slightly smaller to make room for task list
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Reset button
                          TimerControlButton(
                            icon: Icons.refresh_rounded,
                            onPressed: pomodoroService.resetTimer,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),

                          const SizedBox(width: AppConstants.paddingLarge),

                          // Play/Pause button
                          TimerControlButton(
                            icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            onPressed: isRunning
                                ? pomodoroService.pauseTimer
                                : () => _onStartTimer(context, pomodoroService),
                            color: sessionColor,
                            size: 80,
                            iconSize: 40,
                            tooltip: isRunning ? 'Pause Timer' : 
                              (currentSession?.isPaused == true ? 'Resume Timer' : 'Start Timer'),
                          ),

                          const SizedBox(width: AppConstants.paddingLarge),

                          // Skip button
                          TimerControlButton(
                            icon: Icons.skip_next_rounded,
                            onPressed: pomodoroService.skipToNext,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Session counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          '${pomodoroService.completedWorkSessions} sessions completed today',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Quick Tasks List
                      if (activeTasks.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Current Tasks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              // "Add New" button removed as requested
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView.builder(
                            itemCount: activeTasks.length > 3 ? 3 : activeTasks.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemBuilder: (context, index) {
                              final task = activeTasks[index];
                              final isSelected = pomodoroService.currentTask?.id == task.id;

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 8),
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : null,
                                child: InkWell(
                                  onTap: () {
                                    pomodoroService.setCurrentTask(task);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Task "${task.title}" selected'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onBackground.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: TextStyle(
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                  color: isSelected
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme.onBackground,
                                                ),
                                              ),
                                              if (task.description.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  task.description,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Text(
                                          task.progressText,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (activeTasks.length > 3)
                          TextButton(
                            onPressed: () {
                              // Switch to tasks tab
                              final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                              homeScreenState?._onItemTapped(0);
                            },
                            child: const Text('View all tasks'),
                          ),
                      ] else ...[
                        const SizedBox(height: AppConstants.paddingLarge),
                        TextButton.icon(
                          onPressed: () => _showAddTaskDialog(context),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add a task to focus on'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onStartTimer(BuildContext context, PomodoroService pomodoroService) {
    // Simply call the service method which now handles all cases
    pomodoroService.startTimer();
  }

  void _showContinueDialog(BuildContext context, PomodoroService pomodoroService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue to iterate?'),
        content: const Text('Do you want to start the next Pomodoro cycle?'),
        actions: [
          TextButton(
            onPressed: () {
              pomodoroService.continueToNextSession();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              pomodoroService.stopWaitingForContinueDecision();
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  void _showTaskSelector(BuildContext context, TaskService taskService, PomodoroService pomodoroService) {
    final activeTasks = taskService.activeTasks;

    if (activeTasks.isEmpty) {
      // If no tasks available, show dialog to create one
      _showAddTaskDialog(context);
      return;
    }

    final currentTaskId = pomodoroService.currentTask?.id;
    final TextEditingController searchController = TextEditingController();
    List<Task> filteredTasks = List.from(activeTasks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to take more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void filterTasks(String query) {
              setState(() {
                if (query.isEmpty) {
                  filteredTasks = List.from(activeTasks);
                } else {
                  filteredTasks = activeTasks
                      .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              // Make sure the container takes up to 70% of the screen height
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Select a task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (pomodoroService.currentTask != null)
                        TextButton.icon(
                          onPressed: () {
                            pomodoroService.setCurrentTask(null);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear selection'),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddTaskDialog(context);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Task'),
                      ),
                    ],
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: filterTasks,
                    ),
                  ),

                  const Divider(),

                  // Task list
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? Center(
                            child: Text(
                              searchController.text.isEmpty
                                  ? 'No tasks available'
                                  : 'No tasks matching "${searchController.text}"',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              final isSelected = task.id == currentTaskId;

                              return ListTile(
                                leading: Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Completed: ${task.progressText}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                selected: isSelected,
                                onTap: () {
                                  pomodoroService.setCurrentTask(task);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),

                  // Clear selection button at the bottom
                  if (pomodoroService.currentTask != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            pomodoroService.setCurrentTask(null);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Task Selection'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
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
}