import 'package:flutter/material.dart';
import 'pomodoro_model.dart';

class PomodoroSettings {
  /// Timer durations
  final int workDurationMinutes;
  final int shortBreakDurationMinutes; 
  final int longBreakDurationMinutes;
  final int longBreakInterval;
  
  /// Automation settings
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool askToContinue; // New setting for "Continue to iterate?" feature
  
  /// Notification settings
  final bool showNotifications;
  final bool playSound;
  final bool vibrate;
  
  /// Appearance settings
  final bool darkMode;
  final String accentColor;
  
  /// Additional settings
  final int dailyPomodoroTarget;
  final bool keepScreenOn;
  
  PomodoroSettings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.askToContinue = true, // Default to true
    this.showNotifications = true,
    this.playSound = true,
    this.vibrate = true,
    this.darkMode = false,
    this.accentColor = 'tomato',
    this.dailyPomodoroTarget = 8,
    this.keepScreenOn = true,
  });
  
  /// Creates settings from JSON data
  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDurationMinutes: json['workDurationMinutes'] ?? 25,
      shortBreakDurationMinutes: json['shortBreakDurationMinutes'] ?? 5,
      longBreakDurationMinutes: json['longBreakDurationMinutes'] ?? 15,
      longBreakInterval: json['longBreakInterval'] ?? 4,
      autoStartBreaks: json['autoStartBreaks'] ?? false,
      autoStartPomodoros: json['autoStartPomodoros'] ?? false,
      askToContinue: json['askToContinue'] ?? true, // Default to true
      showNotifications: json['showNotifications'] ?? true,
      playSound: json['playSound'] ?? true,
      vibrate: json['vibrate'] ?? true,
      darkMode: json['darkMode'] ?? false,
      accentColor: json['accentColor'] ?? 'tomato',
      dailyPomodoroTarget: json['dailyPomodoroTarget'] ?? 8,
      keepScreenOn: json['keepScreenOn'] ?? true,
    );
  }
  
  /// Converts settings to JSON format for storage
  Map<String, dynamic> toJson() {
    return {
      'workDurationMinutes': workDurationMinutes,
      'shortBreakDurationMinutes': shortBreakDurationMinutes,
      'longBreakDurationMinutes': longBreakDurationMinutes,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'askToContinue': askToContinue, // Include in JSON
      'showNotifications': showNotifications,
      'playSound': playSound,
      'vibrate': vibrate,
      'darkMode': darkMode,
      'accentColor': accentColor,
      'dailyPomodoroTarget': dailyPomodoroTarget,
      'keepScreenOn': keepScreenOn,
    };
  }
  
  /// Creates a copy of settings with updated fields
  PomodoroSettings copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? askToContinue, // Add to copyWith
    bool? showNotifications,
    bool? playSound,
    bool? vibrate,
    bool? darkMode,
    String? accentColor,
    int? dailyPomodoroTarget,
    bool? keepScreenOn,
  }) {
    return PomodoroSettings(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      askToContinue: askToContinue ?? this.askToContinue, // Add to copyWith
      showNotifications: showNotifications ?? this.showNotifications,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
      darkMode: darkMode ?? this.darkMode,
      accentColor: accentColor ?? this.accentColor,
      dailyPomodoroTarget: dailyPomodoroTarget ?? this.dailyPomodoroTarget,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

/// Provider for managing theme settings
class ThemeNotifier extends ChangeNotifier {
  bool _darkMode;
  String _accentColor;
  
  ThemeNotifier({
    bool darkMode = false,
    String accentColor = 'tomato',
  }) : _darkMode = darkMode,
       _accentColor = accentColor;
  
  bool get darkMode => _darkMode;
  String get accentColor => _accentColor;
  
  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
  
  void setAccentColor(String value) {
    _accentColor = value;
    notifyListeners();
  }
}

class UserSettings {
  final String userId;
  final PomodoroSettings pomodoroSettings;
  final bool syncEnabled;
  final String syncFrequency;
  final Map<String, bool> enabledFeatures;

  UserSettings({
    required this.userId,
    PomodoroSettings? pomodoroSettings,
    this.syncEnabled = true,
    this.syncFrequency = 'daily',
    Map<String, bool>? enabledFeatures,
  }) : 
    pomodoroSettings = pomodoroSettings ?? PomodoroSettings(),
    enabledFeatures = enabledFeatures ?? {
      'statistics': true,
      'tasks': true,
      'streaks': true,
      'sync': true,
    };
  
  UserSettings copyWith({
    String? userId,
    PomodoroSettings? pomodoroSettings,
    bool? syncEnabled,
    String? syncFrequency,
    Map<String, bool>? enabledFeatures,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      pomodoroSettings: pomodoroSettings ?? this.pomodoroSettings,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      enabledFeatures: enabledFeatures ?? Map.from(this.enabledFeatures),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pomodoroSettings': pomodoroSettings.toJson(),
      'syncEnabled': syncEnabled,
      'syncFrequency': syncFrequency,
      'enabledFeatures': enabledFeatures,
    };
  }
  
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['userId'] as String,
      pomodoroSettings: PomodoroSettings.fromJson(
        json['pomodoroSettings'] as Map<String, dynamic>
      ),
      syncEnabled: json['syncEnabled'] as bool? ?? true,
      syncFrequency: json['syncFrequency'] as String? ?? 'daily',
      enabledFeatures: Map<String, bool>.from(
        json['enabledFeatures'] as Map<String, dynamic>? ?? {}
      ),
    );
  }
}