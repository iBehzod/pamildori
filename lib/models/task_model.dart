import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final String? projectId;
  final String? userId;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.dueDate,
    this.projectId,
    this.userId,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  double get progress => 
    estimatedPomodoros > 0 ? 
    (completedPomodoros / estimatedPomodoros).clamp(0.0, 1.0) : 0.0;

  String get progressText => 
    '$completedPomodoros/$estimatedPomodoros';

  bool get isDue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return !isCompleted && dueDay.compareTo(today) <= 0;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    String? projectId,
    String? userId,
    bool clearCompletedAt = false,
    bool clearDueDate = false,
    bool clearProjectId = false,
    bool clearUserId = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'projectId': projectId,
      'userId': userId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      estimatedPomodoros: json['estimatedPomodoros'] as int? ?? 1,
      completedPomodoros: json['completedPomodoros'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
      projectId: json['projectId'] as String?,
      userId: json['userId'] as String?,
    );
  }
}


class Project {
  final String id;
  String name;
  String description;
  String color;
  bool isArchived;
  final DateTime createdAt;
  
  Project({
    String? id,
    required this.name,
    this.description = '',
    this.color = 'blue',
    this.isArchived = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
  
  /// Creates a project from JSON data
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      color: json['color'] ?? 'blue',
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  /// Converts project to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Creates a copy of the project with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final int minimumMinutesPerDay;
  final Map<String, int> dailyMinutes; // Format: 'yyyy-MM-dd': minutes

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.minimumMinutesPerDay = 25,
    Map<String, int>? dailyMinutes,
  }) : this.dailyMinutes = dailyMinutes ?? {};
  
  // Add methods for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'minimumMinutesPerDay': minimumMinutesPerDay,
      'dailyMinutes': dailyMinutes,
    };
  }

  factory StreakData.fromJson(Map<String, dynamic> json) {
    final dailyMinMap = json['dailyMinutes'] as Map<String, dynamic>?;
    final Map<String, int> parsedDailyMin = {};
    
    dailyMinMap?.forEach((key, value) {
      parsedDailyMin[key] = value as int;
    });
    
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null 
        ? DateTime.parse(json['lastCompletedDate']) 
        : null,
      minimumMinutesPerDay: json['minimumMinutesPerDay'] ?? 25,
      dailyMinutes: parsedDailyMin,
    );
  }

  bool isStreakMaintainedForToday() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return dailyMinutes.containsKey(todayStr) && 
           dailyMinutes[todayStr]! >= minimumMinutesPerDay;
  }
  
  // Add a method to update the streak data
  StreakData updateWithNewSession(int minutes) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Update the daily minutes
    final updatedDailyMinutes = Map<String, int>.from(dailyMinutes);
    updatedDailyMinutes[todayStr] = (updatedDailyMinutes[todayStr] ?? 0) + minutes;
    
    // Determine if the streak should be updated
    int newCurrentStreak = currentStreak;
    int newLongestStreak = longestStreak;
    
    // If we've met the minimum for today
    if (updatedDailyMinutes[todayStr]! >= minimumMinutesPerDay) {
      // Check if we're continuing a streak
      if (lastCompletedDate != null) {
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
        
        if (lastCompletedDate!.year == yesterday.year && 
            lastCompletedDate!.month == yesterday.month && 
            lastCompletedDate!.day == yesterday.day) {
          // Continuing streak
          newCurrentStreak += 1;
          if (newCurrentStreak > newLongestStreak) {
            newLongestStreak = newCurrentStreak;
          }
        } else if (lastCompletedDate!.year != today.year || 
                  lastCompletedDate!.month != today.month || 
                  lastCompletedDate!.day != today.day) {
          // Broke streak, starting a new one
          newCurrentStreak = 1;
        }
      } else {
        // First streak
        newCurrentStreak = 1;
        newLongestStreak = 1;
      }
    }
    
    return StreakData(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: today,
      minimumMinutesPerDay: minimumMinutesPerDay,
      dailyMinutes: updatedDailyMinutes,
    );
  }
}