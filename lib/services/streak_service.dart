import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import 'storage_service.dart';

class StreakService extends ChangeNotifier {
  final StorageService _storageService;
  StreakData _streakData = StreakData();
  String? _currentUserId;
  
  StreakData get streakData => _streakData;
  int get currentStreak => _streakData.currentStreak;
  int get longestStreak => _streakData.longestStreak;
  int get minimumMinutesPerDay => _streakData.minimumMinutesPerDay;
  bool get isStreakMaintainedToday => _streakData.isStreakMaintainedForToday();
  
  StreakService(this._storageService) {
    _loadStreakData();
  }
  
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    _loadStreakData();
  }
  
  Future<void> _loadStreakData() async {
    if (_currentUserId == null) {
      _streakData = StreakData();
      notifyListeners();
      return;
    }
    
    final streakJson = await _storageService.read('streak_${_currentUserId}');
    if (streakJson != null) {
      try {
        _streakData = StreakData.fromJson(jsonDecode(streakJson));
      } catch (e) {
        debugPrint('Error loading streak data: $e');
        _streakData = StreakData();
      }
    } else {
      _streakData = StreakData();
    }
    
    notifyListeners();
  }
  
  Future<void> _saveStreakData() async {
    if (_currentUserId == null) return;
    
    await _storageService.write(
      'streak_${_currentUserId}',
      jsonEncode(_streakData.toJson()),
    );
  }
  
  Future<void> recordPomodoroSession(int minutes) async {
    if (_currentUserId == null) return;
    
    // Update streak data
    _streakData = _streakData.updateWithNewSession(minutes);
    
    await _saveStreakData();
    notifyListeners();
  }
  
  Future<void> setMinimumMinutesPerDay(int minutes) async {
    if (_currentUserId == null) return;
    
    // Create new streak data with updated minimum
    final updatedStreakData = StreakData(
      currentStreak: _streakData.currentStreak,
      longestStreak: _streakData.longestStreak,
      lastCompletedDate: _streakData.lastCompletedDate,
      minimumMinutesPerDay: minutes,
      dailyMinutes: _streakData.dailyMinutes,
    );
    
    _streakData = updatedStreakData;
    await _saveStreakData();
    notifyListeners();
  }
  
  int getMinutesForToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return _streakData.dailyMinutes[todayStr] ?? 0;
  }
  
  int getMinutesForDate(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _streakData.dailyMinutes[dateStr] ?? 0;
  }
  
  bool hasReachedDailyGoal() {
    return getMinutesForToday() >= minimumMinutesPerDay;
  }
  
  int getDaysUntilStreakLost() {
    if (_streakData.currentStreak == 0) return 0;
    
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // If already completed today, return 1 (tomorrow)
    if (_streakData.dailyMinutes.containsKey(todayStr) && 
        _streakData.dailyMinutes[todayStr]! >= minimumMinutesPerDay) {
      return 1;
    }
    
    // Otherwise return 0 (must complete today)
    return 0;
  }
  
  // Get streak progress for today (percentage)
  double getTodayStreakProgress() {
    final minutesToday = getMinutesForToday();
    if (minimumMinutesPerDay <= 0) return 1.0;
    
    return (minutesToday / minimumMinutesPerDay).clamp(0.0, 1.0);
  }
  
  // Get minutes missing to maintain streak today
  int getMissingMinutesToday() {
    final minutesToday = getMinutesForToday();
    final missing = minimumMinutesPerDay - minutesToday;
    return missing > 0 ? missing : 0;
  }
  
  // Get all dates with any minutes recorded (for calendar view)
  Map<DateTime, int> getRecordedDates() {
    final Map<DateTime, int> result = {};
    
    _streakData.dailyMinutes.forEach((dateStr, minutes) {
      try {
        final parts = dateStr.split('-');
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2]),
        );
        result[date] = minutes;
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    });
    
    return result;
  }

  void _notifyListeners() {
    notifyListeners();
  }
} 