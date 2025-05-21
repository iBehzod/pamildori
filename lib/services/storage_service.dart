import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/auth_model.dart';
import '../models/pomodoro_model.dart';
import '../models/settings_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/pomodoro_statistics.dart'; // Add this import for the proper PomodoroStatistics class

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }
  
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
  
  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
  
  // User settings
  UserSettings? getUserSettings(String userId) {
    final settingsJson = _prefs.getString('user_settings_$userId');
    if (settingsJson == null) return null;
    
    try {
      return UserSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> saveUserSettings(UserSettings settings) async {
    return await _prefs.setString(
      'user_settings_${settings.userId}',
      jsonEncode(settings.toJson()),
    );
  }
  
  // Authentication
  Future<bool> saveAuthData(AuthData authData) async {
    return await _prefs.setString(
      AppConstants.storageKeyAuthData,
      jsonEncode(authData.toJson()),
    );
  }
  
  AuthData? getAuthData() {
    final authJson = _prefs.getString(AppConstants.storageKeyAuthData);
    if (authJson == null) return null;
    
    try {
      return AuthData.fromJson(jsonDecode(authJson));
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> clearAuthData() async {
    return await _prefs.remove(AppConstants.storageKeyAuthData);
  }
  
  // Tasks
  Future<bool> saveTasks(List<Task> tasks) async {
    return await _prefs.setString(
      AppConstants.storageKeyTasks,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }
  
  List<Task> getTasks() {
    final tasksJson = _prefs.getString(AppConstants.storageKeyTasks);
    if (tasksJson == null) return [];
    
    try {
      final List<dynamic> tasksList = jsonDecode(tasksJson);
      return tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> addTask(Task task) async {
    final tasks = getTasks();
    tasks.add(task);
    return await saveTasks(tasks);
  }
  
  Future<bool> updateTask(Task task) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    
    if (index != -1) {
      tasks[index] = task;
      return await saveTasks(tasks);
    }
    
    return false;
  }
  
  Future<bool> deleteTask(String taskId) async {
    final tasks = getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    return await saveTasks(tasks);
  }
  
  Task? getTaskById(String taskId) {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    
    if (index != -1) {
      return tasks[index];
    }
    
    return null;
  }
  
  // Pomodoro Sessions
  Future<bool> savePomodoroSessions(List<PomodoroSession> sessions) async {
    return await _prefs.setString(
      AppConstants.storageKeyPomodoroSessions,
      jsonEncode(sessions.map((session) => session.toJson()).toList()),
    );
  }
  
  List<PomodoroSession> getPomodoroSessions() {
    final sessionsJson = _prefs.getString(AppConstants.storageKeyPomodoroSessions);
    if (sessionsJson == null) return [];
    
    try {
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      return sessionsList
          .map((sessionJson) => PomodoroSession.fromJson(sessionJson))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> addPomodoroSession(PomodoroSession session) async {
    final sessions = getPomodoroSessions();
    sessions.add(session);
    return await savePomodoroSessions(sessions);
  }
  
  Future<bool> updatePomodoroSession(PomodoroSession session) async {
    final sessions = getPomodoroSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    
    if (index != -1) {
      sessions[index] = session;
      return await savePomodoroSessions(sessions);
    }
    
    return false;
  }
  
  // Statistics
  Future<bool> saveStatistics(List<PomodoroStatistics> statistics) async {
    return await _prefs.setString(
      AppConstants.storageKeyStatistics,
      jsonEncode(statistics.map((stats) => stats.toJson()).toList()),
    );
  }
  
  List<PomodoroStatistics> getStatistics() {
    final statsJson = _prefs.getString(AppConstants.storageKeyStatistics);
    if (statsJson == null) return [];
    
    try {
      final List<dynamic> statsList = jsonDecode(statsJson);
      return statsList
          .map((statsJson) => PomodoroStatistics.fromJson(statsJson))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> addOrUpdateStatistics(PomodoroStatistics statistics) async {
    final allStats = getStatistics();
    
    // Try to find existing stats for the same date
    final index = allStats.indexWhere((s) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      final targetDate = DateTime(
        statistics.date.year, 
        statistics.date.month, 
        statistics.date.day,
      );
      return sDate == targetDate;
    });
    
    if (index != -1) {
      allStats[index] = statistics;
    } else {
      allStats.add(statistics);
    }
    
    return await saveStatistics(allStats);
  }
  
  // General methods
  Future<bool> clearAllData() async {
    return await _prefs.clear();
  }
}