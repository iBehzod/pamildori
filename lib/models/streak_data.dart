import 'package:flutter/foundation.dart';

class StreakData {
  /// Current streak (consecutive days meeting minimum requirements)
  final int currentStreak;
  
  /// Longest streak ever achieved
  final int longestStreak;
  
  /// Last date when the user completed their minimum minutes
  final DateTime? lastCompletedDate;
  
  /// Minimum minutes required per day to maintain streak
  final int minimumMinutesPerDay;
  
  /// Map of daily minutes, keyed by date string (YYYY-MM-DD)
  final Map<String, int> dailyMinutes;
  
  /// Create a new StreakData instance
  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.minimumMinutesPerDay = 25,
    Map<String, int>? dailyMinutes,
  }) : dailyMinutes = dailyMinutes ?? {};
  
  /// Check if streak is maintained for today
  bool isStreakMaintainedForToday() {
    final today = DateTime.now();
    final todayStr = _formatDateKey(today);
    
    return dailyMinutes.containsKey(todayStr) && 
           dailyMinutes[todayStr]! >= minimumMinutesPerDay;
  }
  
  /// Create a formatted date key (YYYY-MM-DD)
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Update streak data with a new pomodoro session
  StreakData updateWithNewSession(int minutes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDateKey(today);
    
    // Update daily minutes
    final updatedDailyMinutes = Map<String, int>.from(dailyMinutes);
    updatedDailyMinutes[todayStr] = (updatedDailyMinutes[todayStr] ?? 0) + minutes;
    
    // Check if we've met the minimum for today
    final isTodayComplete = updatedDailyMinutes[todayStr]! >= minimumMinutesPerDay;
    
    // Calculate streak
    int newCurrentStreak = currentStreak;
    int newLongestStreak = longestStreak;
    DateTime? newLastCompleted = lastCompletedDate;
    
    if (isTodayComplete) {
      // Mark today as completed
      newLastCompleted = today;
      
      if (lastCompletedDate == null) {
        // First completion ever
        newCurrentStreak = 1;
      } else {
        final yesterday = today.subtract(const Duration(days: 1));
        final lastCompletedDay = DateTime(
          lastCompletedDate!.year,
          lastCompletedDate!.month,
          lastCompletedDate!.day,
        );
        
        if (lastCompletedDay == yesterday) {
          // Consecutive day - increment streak
          newCurrentStreak += 1;
        } else if (lastCompletedDay == today) {
          // Same day, streak unchanged
        } else {
          // Streak broken - reset to 1
          newCurrentStreak = 1;
        }
      }
      
      // Update longest streak if needed
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }
    }
    
    return StreakData(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: newLastCompleted,
      minimumMinutesPerDay: minimumMinutesPerDay,
      dailyMinutes: updatedDailyMinutes,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'minimumMinutesPerDay': minimumMinutesPerDay,
      'dailyMinutes': dailyMinutes,
    };
  }
  
  /// Create from JSON
  factory StreakData.fromJson(Map<String, dynamic> json) {
    final lastCompletedStr = json['lastCompletedDate'] as String?;
    
    // Convert dailyMinutes from dynamic to <String, int>
    final rawDailyMinutes = json['dailyMinutes'] as Map<String, dynamic>?;
    final Map<String, int> processedDailyMinutes = {};
    
    if (rawDailyMinutes != null) {
      rawDailyMinutes.forEach((key, value) {
        if (value is int) {
          processedDailyMinutes[key] = value;
        } else if (value is num) {
          processedDailyMinutes[key] = value.toInt();
        }
      });
    }
    
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: lastCompletedStr != null ? DateTime.parse(lastCompletedStr) : null,
      minimumMinutesPerDay: json['minimumMinutesPerDay'] as int? ?? 25,
      dailyMinutes: processedDailyMinutes,
    );
  }
  
  /// Create a copy with updated fields
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? minimumMinutesPerDay,
    Map<String, int>? dailyMinutes,
    bool clearLastCompletedDate = false,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: clearLastCompletedDate ? null : (lastCompletedDate ?? this.lastCompletedDate),
      minimumMinutesPerDay: minimumMinutesPerDay ?? this.minimumMinutesPerDay,
      dailyMinutes: dailyMinutes ?? Map<String, int>.from(this.dailyMinutes),
    );
  }
  
  @override
  String toString() => 'StreakData(currentStreak: $currentStreak, '
      'longestStreak: $longestStreak, '
      'lastCompletedDate: $lastCompletedDate, '
      'minimumMinutesPerDay: $minimumMinutesPerDay, '
      'dailyMinutes: $dailyMinutes)';
      
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is StreakData &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastCompletedDate == lastCompletedDate &&
        other.minimumMinutesPerDay == minimumMinutesPerDay &&
        mapEquals(other.dailyMinutes, dailyMinutes);
  }
  
  @override
  int get hashCode => Object.hash(
        currentStreak,
        longestStreak,
        lastCompletedDate,
        minimumMinutesPerDay,
        dailyMinutes,
      );
} 