// lib/models/streak_model.dart
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCompletedDate;
  final int minimumMinutesPerDay;
  final Map<String, int> dailyMinutes; // Format: 'yyyy-MM-dd': minutes

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.minimumMinutesPerDay = 25,
    Map<String, int>? dailyMinutes,
  }) : this.dailyMinutes = dailyMinutes ?? {};

  bool isStreakMaintainedForToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return dailyMinutes.containsKey(todayStr) && 
           dailyMinutes[todayStr]! >= minimumMinutesPerDay;
  }
}