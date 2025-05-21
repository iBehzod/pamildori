import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

/// Types of pomodoro sessions
enum PomodoroType {
  work,
  shortBreak,
  longBreak,
}

/// Status of a pomodoro session
enum PomodoroStatus {
  inProgress,
  completed,
  interrupted,
  paused,
}

/// Individual pomodoro session
class PomodoroSession {
  final String id;
  final PomodoroType type;
  final int durationSeconds;
  int remainingSeconds;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final bool isPaused;
  final DateTime? pausedAt;
  final String? taskId;
  final String? userId;
  final PomodoroStatus status;
  
  PomodoroSession({
    String? id,
    required this.type,
    required this.durationSeconds,
    this.taskId,
    DateTime? startTime,
    this.endTime,
    this.isCompleted = false,
    this.isPaused = false,
    this.pausedAt,
    int? remainingSeconds,
    this.userId,
    this.status = PomodoroStatus.inProgress,
  }) : 
    id = id ?? const Uuid().v4(),
    startTime = startTime ?? DateTime.now(),
    remainingSeconds = remainingSeconds ?? durationSeconds {
    // Ensure remainingSeconds is valid
    if (this.remainingSeconds <= 0) {
      this.remainingSeconds = durationSeconds;
    }
  }
  
  int get durationMinutes => durationSeconds ~/ 60;
  
  double get progress => 1.0 - (remainingSeconds / durationSeconds);
  
  PomodoroSession copyWith({
    String? id,
    PomodoroType? type,
    int? durationSeconds,
    int? remainingSeconds,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    bool? isPaused,
    DateTime? pausedAt,
    String? taskId,
    String? userId,
    PomodoroStatus? status,
    bool clearEndTime = false,
    bool clearPausedAt = false,
    bool clearTaskId = false,
    bool clearUserId = false,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      type: type ?? this.type,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      userId: clearUserId ? null : (userId ?? this.userId),
      status: status ?? this.status,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'durationSeconds': durationSeconds,
      'remainingSeconds': remainingSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'isPaused': isPaused,
      'pausedAt': pausedAt?.toIso8601String(),
      'taskId': taskId,
      'userId': userId,
      'status': status.index,
    };
  }
  
  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    // Handle parsing PomodoroType safely
    PomodoroType parseType() {
      final typeValue = json['type'];
      if (typeValue is int) {
        return PomodoroType.values[typeValue];
      } else if (typeValue is String) {
        // Try to parse as int first
        try {
          return PomodoroType.values[int.parse(typeValue)];
        } catch (e) {
          // If it's a string representation of the enum name
          switch (typeValue.toLowerCase()) {
            case 'work':
              return PomodoroType.work;
            case 'shortbreak':
              return PomodoroType.shortBreak;
            case 'longbreak':
              return PomodoroType.longBreak;
            default:
              return PomodoroType.work; // Default to work
          }
        }
      }
      return PomodoroType.work; // Default to work type
    }

    // Safely parse integer values
    int safeParseInt(dynamic value, int defaultValue) {
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }

    // Safely parse status
    PomodoroStatus parseStatus() {
      final statusValue = json['status'];
      if (statusValue == null) return PomodoroStatus.inProgress;
      
      if (statusValue is int) {
        return PomodoroStatus.values[statusValue];
      } else if (statusValue is String) {
        try {
          return PomodoroStatus.values[int.parse(statusValue)];
        } catch (e) {
          // Default to inProgress if can't parse
          return PomodoroStatus.inProgress;
        }
      }
      return PomodoroStatus.inProgress;
    }

    return PomodoroSession(
      id: json['id'] as String,
      type: parseType(),
      durationSeconds: safeParseInt(json['durationSeconds'], 25 * 60), // Default 25 minutes
      remainingSeconds: safeParseInt(json['remainingSeconds'], json['durationSeconds'] is int ? json['durationSeconds'] : 25 * 60),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : DateTime.now(),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      isCompleted: json['isCompleted'] is bool ? json['isCompleted'] : false,
      isPaused: json['isPaused'] is bool ? json['isPaused'] : false,
      pausedAt: json['pausedAt'] != null 
          ? DateTime.parse(json['pausedAt'] as String) 
          : null,
      taskId: json['taskId'] as String?,
      userId: json['userId'] as String?,
      status: parseStatus(),
    );
  }
}
// PomodoroStatistics class removed - now using the complete implementation from pomodoro_statistics.dart