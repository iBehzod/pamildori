import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pomodoro_model.dart';
import '../../models/task_model.dart';
import '../../models/settings_model.dart'; // Only import settings_model.dart for PomodoroSettings

class PomodoroUtils {
  /// Format seconds into a MM:SS time string
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Format seconds into human readable format
  static String formatTimeVerbose(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '$remainingSeconds ${remainingSeconds == 1 ? 'second' : 'seconds'}';
    } else if (remainingSeconds == 0) {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} and $remainingSeconds ${remainingSeconds == 1 ? 'second' : 'seconds'}';
    }
  }

  /// Calculate the progress of a pomodoro session (0.0 to 1.0)
  static double calculateProgress(PomodoroSession session) {
    if (session.durationSeconds == 0) return 0;
    final elapsed = session.durationSeconds - session.remainingSeconds;
    return elapsed / session.durationSeconds;
  }

  /// Gets the appropriate duration in minutes for a session type based on settings
  static int getDurationForSessionType(
    PomodoroType type,
    PomodoroSettings settings,
  ) {
    switch (type) {
      case PomodoroType.work:
        return settings.workDurationMinutes;
      case PomodoroType.shortBreak:
        return settings.shortBreakDurationMinutes;
      case PomodoroType.longBreak:
        return settings.longBreakDurationMinutes;
    }
  }

  /// Get the next session type based on current session and pomodoro count
  static PomodoroType getNextSessionType(
    PomodoroType currentType, 
    int completedSessions,
    int longBreakInterval,
  ) {
    // If current is work, next is a break (short or long based on count)
    if (currentType == PomodoroType.work) {
      // Check if it's time for a long break (e.g., after 4 work sessions)
      if ((completedSessions % longBreakInterval) == 0) {
        return PomodoroType.longBreak;
      } else {
        return PomodoroType.shortBreak;
      }
    } 
    // If current is a break (short or long), next is work
    else {
      return PomodoroType.work;
    }
  }

  /// Gets a user-friendly name for the session type
  static String getNameForSessionType(PomodoroType type) {
    switch (type) {
      case PomodoroType.work:
        return 'Focus';
      case PomodoroType.shortBreak:
        return 'Short Break';
      case PomodoroType.longBreak:
        return 'Long Break';
      default:
        return 'Focus';
    }
  }

  /// Get appropriate color for the session type
  static Color getColorForSessionType(PomodoroType type, ThemeData theme) {
    switch (type) {
      case PomodoroType.work:
        return theme.colorScheme.primary;
      case PomodoroType.shortBreak:
        return Colors.green;
      case PomodoroType.longBreak:
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Get a formatted date for display in statistics
  static String formatDate(DateTime date, {bool includeYear = false}) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final formatter = includeYear
          ? DateFormat('MMM d, y')
          : DateFormat('MMM d');
      return formatter.format(date);
    }
  }

  /// Estimate time to complete remaining tasks
  static String estimateCompletionTime(List<Task> tasks, PomodoroSettings settings) {
    final incompleteTasks = tasks.where((task) => !task.isCompleted);

    if (incompleteTasks.isEmpty) {
      return 'All tasks completed';
    }

    int totalPomodorosNeeded = 0;

    for (final task in incompleteTasks) {
      totalPomodorosNeeded += max(1, task.estimatedPomodoros - task.completedPomodoros);
    }

    final totalMinutes = totalPomodorosNeeded * settings.workDurationMinutes;

    if (totalMinutes < 60) {
      return '$totalMinutes minutes';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '$hours ${hours == 1 ? 'hour' : 'hours'}${minutes > 0 ? ' $minutes min' : ''}';
    }
  }

  /// Calculate daily goal progress (0-1) based on completed pomodoros
  static double calculateDailyGoalProgress(
    int completedToday, 
    int dailyTarget,
  ) {
    if (dailyTarget <= 0) return 0.0;
    return min(1.0, completedToday / dailyTarget);
  }

  /// Generate appropriate motivation message based on progress
  static String getMotivationMessage(double progress) {
    if (progress >= 1.0) {
      return "Excellent! You've reached your daily goal.";
    } else if (progress >= 0.8) {
      return "Almost there! Keep going, you're doing great.";
    } else if (progress >= 0.5) {
      return "You're making good progress today!";
    } else if (progress >= 0.25) {
      return "You've started well, keep up the momentum!";
    } else {
      return "Let's focus and achieve your goals today!";
    }
  }

  /// Calculate total focus time in minutes from completed sessions
  static int calculateTotalFocusTime(List<PomodoroSession> completedSessions) {
    // Count only completed work sessions
    final workSessions = completedSessions
        .where((session) => 
            session.type == PomodoroType.work && 
            session.isCompleted)
        .toList();
    
    // Sum up the duration of completed work sessions
    final totalSeconds = workSessions.fold(0, 
        (sum, session) => sum + (session.durationSeconds - session.remainingSeconds));
    
    // Convert to minutes
    return totalSeconds ~/ 60;
  }

  /// Convert minutes to a human-readable format (e.g., "2h 30m")
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 
          ? '${hours}h ${remainingMinutes}m'
          : '${hours}h';
    }
  }

  /// Calculates total completed work minutes for stats
  static int calculateTotalWorkMinutes(List<PomodoroSession> sessions) {
    return sessions
        .where((session) => 
            session.type == PomodoroType.work && 
            session.status == PomodoroStatus.completed)
        .fold(0, (sum, session) => sum + session.durationMinutes);
  }

  /// Calculates focus rating (0-100%) based on completed vs. interrupted sessions
  static double calculateFocusRating(List<PomodoroSession> sessions) {
    final workSessions = sessions.where(
      (session) => session.type == PomodoroType.work
    ).toList();

    if (workSessions.isEmpty) return 0.0;

    final completedSessions = workSessions.where(
      (session) => session.status == PomodoroStatus.completed
    ).length;

    return (completedSessions / workSessions.length) * 100;
  }
}