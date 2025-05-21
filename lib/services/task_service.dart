import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'storage_service.dart';

class TaskService extends ChangeNotifier {
  final StorageService _storageService;
  List<Task> _tasks = [];
  Task? _selectedTask;
  String? _currentUserId;
  
  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;
  
  TaskService(this._storageService) {
    _loadTasks();
  }
  
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    _loadTasks();
  }

  // Get active tasks
  List<Task> get activeTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }
  
  // Get completed tasks
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }
  
  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      
      _tasks[index] = updatedTask;
      
      // If this was the selected task, update it
      if (_selectedTask != null && _selectedTask!.id == taskId) {
        _selectedTask = updatedTask;
      }
      
      await _storageService.updateTask(updatedTask);
      notifyListeners();
    }
  }
  
  // Add task directly with Task object
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    
    // Re-sort tasks
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    await _storageService.addTask(task);
    notifyListeners();
  }
  
  // Update an existing task
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    
    if (index != -1) {
      _tasks[index] = task;
      await _storageService.updateTask(task);
      
      // If this was the selected task, update it
      if (_selectedTask != null && _selectedTask!.id == task.id) {
        _selectedTask = task;
      }
      
      notifyListeners();
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _storageService.deleteTask(taskId);
    
    // If this was the selected task, clear selection
    if (_selectedTask != null && _selectedTask!.id == taskId) {
      _selectedTask = null;
    }
    
    notifyListeners();
  }
  
  // Clear all completed tasks
  Future<void> clearCompletedTasks() async {
    final completedTaskIds = _tasks
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();
    
    // Remove from list
    _tasks.removeWhere((task) => task.isCompleted);
    
    // Remove from storage
    for (final taskId in completedTaskIds) {
      await _storageService.deleteTask(taskId);
      
      // If this was the selected task, clear selection
      if (_selectedTask != null && _selectedTask!.id == taskId) {
        _selectedTask = null;
      }
    }
    
    notifyListeners();
  }
  
  // Select a task
  void selectTask(Task task) {
    _selectedTask = task;
    notifyListeners();
  }
  
  // Load tasks from storage
  Future<void> _loadTasks() async {
    _tasks = _storageService.getTasks();
    notifyListeners();
  }
}