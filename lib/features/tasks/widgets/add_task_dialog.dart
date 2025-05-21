import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../models/task_model.dart';
import '../../../services/task_service.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task; // Null for new task, non-null for editing
  
  const AddTaskDialog({
    Key? key,
    this.task,
  }) : super(key: key);

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late int _estimatedPomodoros;
  DateTime? _dueDate;
  
  bool get _isEditing => widget.task != null;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with existing data if editing
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _estimatedPomodoros = task?.estimatedPomodoros ?? 1;
    _dueDate = task?.dueDate;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      final taskService = Provider.of<TaskService>(context, listen: false);
      
      if (_isEditing) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          estimatedPomodoros: _estimatedPomodoros,
          dueDate: _dueDate,
        );
        
        taskService.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          estimatedPomodoros: _estimatedPomodoros,
          completedPomodoros: 0,
          isCompleted: false,
          dueDate: _dueDate,
          createdAt: DateTime.now(),
        );
        
        taskService.addTask(newTask);
      }
      
      Navigator.of(context).pop();
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dueDate ?? now;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Select Due Date',
    );
    
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Task' : 'Add New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'What do you need to do?',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                maxLength: 100,
              ),
              
              const SizedBox(height: 8),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about this task',
                ),
                maxLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
              ),
              
              const SizedBox(height: 16),
              
              // Estimated pomodoros
              Row(
                children: [
                  Text(
                    'Estimated Pomodoros: $_estimatedPomodoros',
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _estimatedPomodoros > 1
                        ? () => setState(() => _estimatedPomodoros--)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _estimatedPomodoros < 10
                        ? () => setState(() => _estimatedPomodoros++)
                        : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Due date selection
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _dueDate == null
                            ? 'Set Due Date (Optional)'
                            : 'Due: ${DateTimeUtils.formatDateShort(_dueDate!)}',
                        style: TextStyle(
                          color: _dueDate == null
                              ? theme.hintColor
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dueDate = null),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
} 