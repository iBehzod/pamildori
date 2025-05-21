import 'package:flutter/material.dart';

/// Application constants
class AppConstants {
  // App information
  static const String appName = 'Pamildori';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Pomodoro timer app with tasks and statistics';
  
  // Storage keys
  static const String storageKeySettings = 'settings';
  static const String storageKeyTasks = 'tasks';
  static const String storageKeyProjects = 'projects';
  static const String storageKeyPomodoroSessions = 'pomodoro_sessions';
  static const String storageKeyActiveSession = 'active_session';
  static const String storageKeyStatistics = 'statistics';
  static const String storageKeyCurrentUserId = 'current_user_id';
  static const String storageKeyAuthData = 'auth_data';
  
  // Default pomodoro settings
  static const int defaultPomodoroMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultLongBreakInterval = 4;
  static const bool defaultAutoStartBreaks = true;
  static const bool defaultAutoStartPomodoros = false;
  static const bool defaultAlarmSound = true;
  static const bool defaultTickingSound = false;
  static const bool defaultVibration = true;
  static const bool defaultDarkMode = false;
  static const bool defaultAskToContinue = true;
  static const String defaultAccentColor = 'tomato';
  
  // Default streak settings
  static const int defaultMinimumMinutesPerDay = 25;
  
  // UI constants
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Colors
  static const Map<String, Color> accentColors = {
    'tomato': Color(0xFFFF6347),
    'coral': Color(0xFFFF7F50),
    'crimson': Color(0xFFDC143C),
    'orange': Color(0xFFFFA500),
    'gold': Color(0xFFFFD700),
    'lime': Color(0xFF32CD32),
    'teal': Color(0xFF008080),
    'cyan': Color(0xFF00FFFF),
    'blue': Color(0xFF0000FF),
    'purple': Color(0xFF800080),
    'magenta': Color(0xFFFF00FF),
    'pink': Color(0xFFFFC0CB),
  };
  
  // Route constants
  static const String routeRoot = '/';
  static const String routeHome = '/home';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeSettings = '/settings';
  static const String routeTasks = '/tasks';
  static const String routeStatistics = '/statistics';

  // API Endpoints
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const String apiAuthEndpoint = '$apiBaseUrl/auth';
  static const String apiTasksEndpoint = '$apiBaseUrl/tasks';
  static const String apiUsersEndpoint = '$apiBaseUrl/users';

  // Default values
  static const int defaultWorkDurationMinutes = 25;
  static const int defaultShortBreakDurationMinutes = 5;
  static const int defaultLongBreakDurationMinutes = 15;
  static const int defaultDailyPomodoroGoal = 8;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultPomodoroSound = 'notification.mp3';
  
  // Sound assets
  static const String soundBell = 'sounds/bell.mp3';
  static const String soundBreak = 'sounds/break.mp3';
  static const String soundComplete = 'sounds/complete.mp3';
  static const String soundStart = 'sounds/start.mp3';

  // Padding values
  static const double paddingTiny = 4.0;
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Border radius values
  static const double borderRadiusCircular = 100.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;

  // Button sizes
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Pomodoro related constants
  static const int defaultPomodorosUntilLongBreak = 4;
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection and try again.';
  static const String authFailed = 'Authentication failed. Please check your credentials.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
}

class SuccessMessages {
  static const String signUpSuccess = 'Account created successfully!';
  static const String signInSuccess = 'Signed in successfully!';
  static const String settingsSaved = 'Settings saved successfully!';
  static const String taskAdded = 'Task added successfully!';
  static const String taskUpdated = 'Task updated successfully!';
  static const String taskDeleted = 'Task deleted successfully!';
}