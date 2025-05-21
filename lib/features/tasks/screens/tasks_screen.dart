import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/task_model.dart';
import '../../../services/pomodoro_service.dart';
import '../../../services/task_service.dart';
import '../widgets/task_list.dart';
import '../widgets/add_task_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to tab changes to update the UI
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    // Force a rebuild when tab changes to update the FAB visibility
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Tasks',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            
            // Tab bar for active/completed
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveTasksTab(),
                  _buildCompletedTasksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Only show FAB on Active tab
      floatingActionButton: _tabController.index == 0 
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              tooltip: 'Add Task',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildActiveTasksTab() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TaskList(
            tasks: taskService.activeTasks,
            emptyMessage: 'No active tasks\nAdd a task to get started!',
          ),
        );
      },
    );
  }

  Widget _buildCompletedTasksTab() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              if (taskService.completedTasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showClearCompletedDialog(context),
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text('Clear completed'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TaskList(
                  tasks: taskService.completedTasks,
                  emptyMessage: 'No completed tasks yet',
                  showAddButtonOnEmpty: false,
                ),
              ),
            ],
          ),
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
  
  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(
          'Are you sure you want to delete all completed tasks? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskService = Provider.of<TaskService>(context, listen: false);
              taskService.clearCompletedTasks();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed tasks cleared'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}