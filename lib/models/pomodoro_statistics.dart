import 'package:uuid/uuid.dart';

/// Represents pomodoro statistics for a specific day
class PomodoroStatistics {
  final String id;
  final DateTime date;
  final int completedPomodoros;
  final int totalFocusMinutes;
  final int totalBreakMinutes;
  final double productivityScore; // 0.0 - 1.0
  
  /// Create a new PomodoroStatistics instance
  PomodoroStatistics({
    String? id,
    required this.date,
    this.completedPomodoros = 0,
    this.totalFocusMinutes = 0,
    this.totalBreakMinutes = 0,
    this.productivityScore = 0.0,
  }) : id = id ?? const Uuid().v4();

  /// Create a copy with specified fields updated
  PomodoroStatistics copyWith({
    String? id,
    DateTime? date,
    int? completedPomodoros,
    int? totalFocusMinutes,
    int? totalBreakMinutes,
    double? productivityScore,
  }) {
    return PomodoroStatistics(
      id: id ?? this.id,
      date: date ?? this.date,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      productivityScore: productivityScore ?? this.productivityScore,
    );
  }

  /// Convert this model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'completedPomodoros': completedPomodoros,
      'totalFocusMinutes': totalFocusMinutes,
      'totalBreakMinutes': totalBreakMinutes,
      'productivityScore': productivityScore,
    };
  }

  /// Create a model from JSON
  factory PomodoroStatistics.fromJson(Map<String, dynamic> json) {
    return PomodoroStatistics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      completedPomodoros: json['completedPomodoros'] as int,
      totalFocusMinutes: json['totalFocusMinutes'] as int,
      totalBreakMinutes: json['totalBreakMinutes'] as int,
      productivityScore: (json['productivityScore'] as num).toDouble(),
    );
  }
}