import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/pomodoro_model.dart';
import '../models/settings_model.dart';
import '../models/task_model.dart';
import '../models/pomodoro_statistics.dart'; // Add import for PomodoroStatistics
import 'storage_service.dart';
import 'sound_service.dart';
import 'notification_service.dart';
import 'streak_service.dart';
import 'task_service.dart'; // Add this import

class PomodoroService extends ChangeNotifier {
  // Services
  final StorageService _storageService;
  final TaskService _taskService; // Add TaskService field
  SoundService? _soundService;
  NotificationService? _notificationService;
  StreakService? _streakService;
  
  // State
  PomodoroSettings _settings;
  PomodoroSession? _currentSession;
  List<PomodoroSession> _sessionHistory = [];
  Task? _currentTask;
  int _completedPomodoros = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _waitingForContinueDecision = false;

  // Getters
  PomodoroSettings get settings => _settings;
  PomodoroSession? get currentSession => _currentSession;
  List<PomodoroSession> get sessionHistory => _sessionHistory;
  Task? get currentTask => _currentTask;
  int get completedPomodoros => _completedPomodoros;
  bool get isRunning => _isRunning;
  bool get waitingForContinueDecision => _waitingForContinueDecision;
  bool get isWaitingForContinueDecision => _waitingForContinueDecision;
  int get completedWorkSessions => _completedPomodoros;
  
  PomodoroService(this._storageService, this._taskService) 
      : _settings = PomodoroSettings() {
    _loadSettings();
    _loadSessionHistory();
  }

  // Service setters
  void setSoundService(SoundService soundService) {
    _soundService = soundService;
  }

  void setNotificationService(NotificationService notificationService) {
    _notificationService = notificationService;
  }

  void setStreakService(StreakService streakService) {
    _streakService = streakService;
  }

  void setCurrentTask(Task? task) {
    _currentTask = task;
    
    // If there's an active session, associate it with this task (or clear association)
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        taskId: task?.id,
      );
    }
    
    notifyListeners();
  }

  // Initialize a new Pomodoro session
  void startNewSession({
    required PomodoroType type,
    Task? task,
  }) {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Get the appropriate duration based on session type and settings
    final durationMinutes = _getDurationMinutes(type);
    
    // Create a new session
    _currentSession = PomodoroSession(
      type: type,
      durationSeconds: durationMinutes * 60,
      taskId: task?.id,
    );
    
    _currentTask = task;
    _isRunning = true;
    
    // Play start sound based on session type
    if (type == PomodoroType.work) {
      _soundService?.playStartSound();
    } else {
      _soundService?.playBreakSound();
    }
    
    // Start the timer
    _startTimer();
    
    notifyListeners();
  }

  // Resume a paused session
  void resumeSession() {
    if (_currentSession == null || !_currentSession!.isPaused) return;
    
    // Update the session
    _currentSession = _currentSession!.copyWith(
      isPaused: false,
      pausedAt: null,
      clearPausedAt: true, // Explicitly clear pausedAt state
    );
    
    _isRunning = true;
    
    // Start the timer
    _startTimer();
    
    notifyListeners();
  }

  // Pause the current session
  void pauseSession() {
    if (_currentSession == null || _currentSession!.isPaused) return;
    
    _timer?.cancel(); // Cancel the active timer
    _timer = null;    // **Crucial:** Nullify the service's reference
    
    _currentSession = _currentSession!.copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
    );
    
    _isRunning = false; // Update state AFTER cancelling timer
    notifyListeners();
  }

  // Skip the current session
void skipSession() {
  if (_currentSession == null) return;
  
  // Don't allow skipping work sessions
  if (_currentSession!.type == PomodoroType.work) {
    return; // Early exit if trying to skip a work session
  }
  
  // Cancel the timer
  _timer?.cancel();
  
  // Add the current session to history as skipped
  _sessionHistory.add(_currentSession!.copyWith(
    isCompleted: false,
    endTime: DateTime.now(),
  ));
  
  // Save session history
  _saveSessionHistory();
  
  // Start the next work session
  startNewSession(type: PomodoroType.work, task: _currentTask);
}

  // Reset the current session and start over
  void resetSession() {
    if (_currentSession == null) return;
    
    _timer?.cancel(); // Cancel the active timer
    _timer = null;    // **Crucial:** Nullify the service's reference
    
    final sessionType = _currentSession!.type;
    // Reset state BEFORE starting new session
    _isRunning = false; 
    _currentSession = null; 
    _currentTask = null; // Assuming task should also reset

    // Create a new session (this sets _isRunning = true and calls _startTimer)
    startNewSession(
      type: sessionType,
      task: _currentTask, // Task is null now
    );
  }

  // Complete the current session
  void _completeSession() {
    // Check if already processing completion or no session
    if (_currentSession == null) return; // Simplified check: only need to check session

    // Immediately mark as not running and clear timer reference
    _isRunning = false; 
    _timer?.cancel(); 
    _timer = null;    

    // Capture session details before clearing _currentSession
    final completedSession = _currentSession!.copyWith(
      isCompleted: true,
      endTime: DateTime.now(),
      remainingSeconds: 0,
    );
    final wasWorkSession = completedSession.type == PomodoroType.work;
    final relatedTask = _currentTask; // Keep reference to task if needed

    // Clear the main session reference now
    _currentSession = null; 
    
    // Add to history
    _sessionHistory.add(completedSession);
    
    // Play completion sound
    _soundService?.playCompleteSound();
    
    // Show appropriate notification based on session type
    if (completedSession.type == PomodoroType.work) {
      _notificationService?.showWorkCompleteNotification();
    } else if (completedSession.type == PomodoroType.shortBreak) {
      _notificationService?.showBreakCompleteNotification();
    } else if (completedSession.type == PomodoroType.longBreak) {
      _notificationService?.showLongBreakCompleteNotification();
    }
    
    // If it was a work session, increment completed pomodoros and update streak/task
    if (wasWorkSession) {
      _completedPomodoros++;
      
      final sessionMinutes = _getDurationMinutes(PomodoroType.work);
      _streakService?.recordPomodoroSession(sessionMinutes);
      
      if (relatedTask != null) {
        final newCompletedCount = relatedTask.completedPomodoros + 1;
        bool shouldMarkComplete = newCompletedCount == relatedTask.estimatedPomodoros;

        final updatedTask = relatedTask.copyWith(
          completedPomodoros: newCompletedCount,
          isCompleted: shouldMarkComplete,
          completedAt: shouldMarkComplete ? DateTime.now() : relatedTask.completedAt,
        );

        _taskService.updateTask(updatedTask);

        // If the task was just completed, ensure _currentTask remains null
        if (shouldMarkComplete) {
          // _currentTask is already null from above, but setCurrentTask notifies
          setCurrentTask(null); 
        } else {
           // Update _currentTask ONLY if the task *wasn't* completed
           // This state is complex: if another session starts immediately, 
           // setCurrentTask might be called again anyway. Let's keep it null here.
           // If _startNextSession needs the task, it should use the `relatedTask` variable.
        }
      }
    }
    
    // Save session history
    _saveSessionHistory();
    
    // Start the next appropriate session based on settings
    // Pass the just-completed task if needed by startNextSession logic
    _startNextSession(completedTask: wasWorkSession ? relatedTask : null); 
  }

  // Start the next appropriate session based on current state and settings
  // Modify to accept optional completedTask parameter
  void _startNextSession({Task? completedTask}) { 
    PomodoroType nextType;
    bool wasWorkSession = completedTask != null; // Infer if last session was work

    // If the last session was work
    if (wasWorkSession) {
      // Determine break type
      if (_completedPomodoros % _settings.longBreakInterval == 0) {
        nextType = PomodoroType.longBreak;
      } else {
        nextType = PomodoroType.shortBreak;
      }

      // Use the completed task for the break if auto-starting
      final taskForNextSession = _settings.autoStartBreaks ? completedTask : null;
      
      if (_settings.autoStartBreaks) {
        startNewSession(type: nextType, task: taskForNextSession);
      } else {
        // Reset for manual start
        _currentSession = PomodoroSession(
          type: nextType,
          durationSeconds: _getDurationMinutes(nextType) * 60,
          taskId: taskForNextSession?.id, // Keep task association if desired, even if paused
          isPaused: true,
        );
         _currentTask = taskForNextSession; // Reflect the associated task
        _isRunning = false;
        notifyListeners();
      }
    } else { // Last session was a break or initial state
      nextType = PomodoroType.work;
      
      // Decide which task to use for the next work session
      // Should we reuse the task from the *previous* work session?
      // Or rely on whatever _currentTask is (could be null)?
      // Let's assume we try to reuse the task if available, otherwise null.
      final taskForNextSession = _currentTask; 

      if (_settings.askToContinue) {
        _waitingForContinueDecision = true;
        _isRunning = false;
        notifyListeners();
        // We need to preserve the intended next task when waiting
        // Let's keep _currentTask as is for now.
        return;
      }
      
      if (_settings.autoStartPomodoros) {
        startNewSession(type: nextType, task: taskForNextSession);
      } else {
        // Reset for manual start
        _currentSession = PomodoroSession(
          type: nextType,
          durationSeconds: _getDurationMinutes(nextType) * 60,
          taskId: taskForNextSession?.id, 
          isPaused: true,
        );
        // _currentTask is already set appropriately above
        _isRunning = false;
        notifyListeners();
      }
    }
  }
  
  // Handle user's continue decision (ensure task context is right)
  void handleContinueDecision(bool shouldContinue) {
    _waitingForContinueDecision = false;
    
    if (shouldContinue) {
      // User wants to continue, start the next work session with the task
      // that was current when the break ended.
      startNewSession(type: PomodoroType.work, task: _currentTask);
    } else {
      // User doesn't want to continue, reset the session state
      _currentSession = null;
      _currentTask = null;
      _isRunning = false;
      notifyListeners();
    }
  }

  // Continue to next session when user chooses "Yes"
  void continueToNextSession() {
    handleContinueDecision(true);
  }
  
  // Stop waiting for continue decision when user chooses "No"
  void stopWaitingForContinueDecision() {
    handleContinueDecision(false);
  }

  // Get duration in minutes based on session type
  int _getDurationMinutes(PomodoroType type) {
    switch (type) {
      case PomodoroType.work:
        return _settings.workDurationMinutes;
      case PomodoroType.shortBreak:
        return _settings.shortBreakDurationMinutes;
      case PomodoroType.longBreak:
        return _settings.longBreakDurationMinutes;
      default:
        return _settings.workDurationMinutes;
    }
  }

  // Start the timer countdown
  void _startTimer() {
    if (_currentSession == null) return;
    
    // Cancel any potentially lingering timer before starting a new one.
    _timer?.cancel(); 
    _timer = null; // Ensure timer is null before creating a new one
    
    // Create the new timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Ensure session hasn't been nulled or paused externally
      if (_currentSession == null || _currentSession!.isPaused || !_isRunning) {
        timer.cancel(); // Stop this timer if state is invalid
        _timer = null;  // Nullify reference
        return;
      }

      // Check if time is up
      if (_currentSession!.remainingSeconds <= 1) {
        timer.cancel(); // Stop this timer instance before completing
        _timer = null;  // Nullify reference
        _completeSession(); // Handle session completion (will also set _isRunning = false)
      } else {
        // Decrement the remaining time
        _currentSession = _currentSession!.copyWith(
          remainingSeconds: _currentSession!.remainingSeconds - 1,
        );
        notifyListeners(); // Notify UI on each tick
      }
    });
  }

  // Update settings
  Future<void> updateSettings(PomodoroSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final settingsJson = await _storageService.read(AppConstants.storageKeySettings);
      if (settingsJson != null) {
        _settings = PomodoroSettings.fromJson(json.decode(settingsJson));
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    notifyListeners();
  }

  // Save settings to storage
  Future<void> _saveSettings() async {
    try {
      await _storageService.write(
        AppConstants.storageKeySettings,
        json.encode(_settings.toJson()),
      );
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Load session history from storage
  Future<void> _loadSessionHistory() async {
    try {
      final historyJson = await _storageService.read(AppConstants.storageKeyPomodoroSessions);
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _sessionHistory = decoded
            .map((item) => PomodoroSession.fromJson(item))
            .toList();
        
        // Count completed work sessions for today
        final today = DateTime.now();
        final startOfToday = DateTime(today.year, today.month, today.day);
        _completedPomodoros = _sessionHistory
            .where((session) => 
                session.type == PomodoroType.work && 
                session.isCompleted && 
                session.endTime != null &&
                session.endTime!.isAfter(startOfToday))
            .length;
      }
    } catch (e) {
      print('Error loading session history: $e');
    }
  }

  // Save session history to storage
  Future<void> _saveSessionHistory() async {
    try {
      final historyJson = json.encode(
        _sessionHistory.map((session) => session.toJson()).toList(),
      );
      await _storageService.write(
        AppConstants.storageKeyPomodoroSessions,
        historyJson,
      );
    } catch (e) {
      print('Error saving session history: $e');
    }
  }

  // Methods to match function calls in home_screen.dart
  void startTimer() {
    if (_currentSession == null) {
      // If there's no session, create a work session
      startNewSession(type: PomodoroType.work, task: _currentTask);
      return;
    }
    
    if (_isRunning) return; // Already running
    
    if (_currentSession!.isPaused) {
      // Resume if paused
      resumeSession();
    } else {
      // Otherwise start timer
      _isRunning = true;
      _startTimer();
      notifyListeners();
    }
  }
  
  void pauseTimer() {
    if (_currentSession != null && _isRunning) {
      pauseSession();
    }
  }
  
  void resetTimer() {
    resetSession();
  }
  
  void skipToNext() {
    skipSession();
  }
  
  // New method to restore state when app starts
  Future<void> restoreState() async {
    await _loadSettings();
    await _loadSessionHistory();
    
    // Check if there was an active session
    final activeSessionJson = await _storageService.read(AppConstants.storageKeyActiveSession);
    if (activeSessionJson != null) {
      try {
        final sessionData = json.decode(activeSessionJson);
        final activeSession = PomodoroSession.fromJson(sessionData);
        
        // Check if the session is still valid (not expired)
        final now = DateTime.now();
        final startTime = activeSession.startTime;
        final elapsedSeconds = now.difference(startTime).inSeconds;
        
        if (elapsedSeconds < activeSession.durationSeconds) {
          // Session is still valid, restore it
          _currentSession = activeSession.copyWith(
            remainingSeconds: activeSession.durationSeconds - elapsedSeconds,
            isPaused: true,
          );
          
          // Restore associated task if any
          if (activeSession.taskId != null) {
            _currentTask = await _storageService.getTaskById(activeSession.taskId!);
          }
          
          notifyListeners();
        }
      } catch (e) {
        print('Error restoring active session: $e');
      }
    }
  }

  void startSession({required PomodoroType type, Task? task}) {
    startNewSession(type: type, task: task);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // Get the total focus minutes completed today
  int getTotalFocusMinutesToday() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    
    return _sessionHistory
        .where((session) => 
            session.type == PomodoroType.work && 
            session.isCompleted && 
            session.endTime != null &&
            session.endTime!.isAfter(startOfToday))
        .fold(0, (sum, session) {
          final durationMinutes = session.durationSeconds ~/ 60;
          return sum + durationMinutes;
        });
  }
  
  // Get statistics for the current week
  List<PomodoroStatistics> getWeeklyStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find the start of the week (Monday)
    final daysToMonday = (now.weekday - 1) % 7;
    final startOfWeek = today.subtract(Duration(days: daysToMonday));
    
    // Create empty statistics for each day of the week
    final weekStats = List<PomodoroStatistics>.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return PomodoroStatistics(
        date: date,
        completedPomodoros: 0,
        totalFocusMinutes: 0,
      );
    });
    
    // Safety check: limit session history to reasonable size to prevent performance issues
    final relevantSessions = _sessionHistory
        .where((session) => 
            session.endTime != null &&
            session.endTime!.isAfter(startOfWeek.subtract(const Duration(days: 1))))
        .toList();
    
    // Fill in the stats from relevant session history
    for (final session in relevantSessions) {
      if (session.type == PomodoroType.work && 
          session.isCompleted && 
          session.endTime != null) {
        
        final sessionDate = session.endTime!;
        final sessionDay = DateTime(
          sessionDate.year, 
          sessionDate.month, 
          sessionDate.day
        );
        
        // Check if the session is in the current week
        if (sessionDay.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
            sessionDay.isBefore(startOfWeek.add(const Duration(days: 7)))) {
          
          // Find the day index (0 = Monday, 6 = Sunday)
          final dayDifference = sessionDay.difference(startOfWeek).inDays;
          
          if (dayDifference >= 0 && dayDifference < 7) {
            final durationMinutes = session.durationSeconds ~/ 60;
            
            // Update statistics for the day
            weekStats[dayDifference] = weekStats[dayDifference].copyWith(
              completedPomodoros: weekStats[dayDifference].completedPomodoros + 1,
              totalFocusMinutes: weekStats[dayDifference].totalFocusMinutes + durationMinutes,
            );
          }
        }
      }
    }
    
    return weekStats;
  }

  // Get statistics for the last month (last 30 days)
  List<PomodoroStatistics> getMonthlyStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // Create empty statistics for each day of the month
    final monthStats = List<PomodoroStatistics>.generate(daysInMonth, (index) {
      final date = DateTime(now.year, now.month, index + 1);
      return PomodoroStatistics(
        date: date,
        completedPomodoros: 0,
        totalFocusMinutes: 0,
      );
    });
    
    // Safety check: limit session history to relevant month to prevent performance issues
    final relevantSessions = _sessionHistory
        .where((session) => 
            session.endTime != null &&
            session.endTime!.isAfter(startOfMonth.subtract(const Duration(days: 1))))
        .toList();
    
    // Fill in the stats from session history
    for (final session in relevantSessions) {
      if (session.type == PomodoroType.work && 
          session.isCompleted && 
          session.endTime != null) {
        
        final sessionDate = session.endTime!;
        final sessionDay = DateTime(
          sessionDate.year, 
          sessionDate.month, 
          sessionDate.day
        );
        
        // Check if the session is in the current month
        if (sessionDay.year == startOfMonth.year && sessionDay.month == startOfMonth.month) {
          final dayOfMonth = sessionDay.day - 1; // 0-indexed array
          
          if (dayOfMonth >= 0 && dayOfMonth < daysInMonth) {
            final durationMinutes = session.durationSeconds ~/ 60;
            
            // Update statistics for the day
            monthStats[dayOfMonth] = monthStats[dayOfMonth].copyWith(
              completedPomodoros: monthStats[dayOfMonth].completedPomodoros + 1,
              totalFocusMinutes: monthStats[dayOfMonth].totalFocusMinutes + durationMinutes,
            );
          }
        }
      }
    }
    
    return monthStats;
  }

  // Get statistics for the last year (by month)
  List<PomodoroStatistics> getYearlyStatistics() {
    final now = DateTime.now();
    final currentYear = now.year;
    final startOfYear = DateTime(currentYear, 1, 1);
    
    // Create empty statistics for each month of the year
    final yearStats = List<PomodoroStatistics>.generate(12, (index) {
      final date = DateTime(currentYear, index + 1, 1);
      return PomodoroStatistics(
        date: date,
        completedPomodoros: 0,
        totalFocusMinutes: 0,
      );
    });
    
    // Safety check: limit session history to relevant year to prevent performance issues
    final relevantSessions = _sessionHistory
        .where((session) => 
            session.endTime != null &&
            session.endTime!.isAfter(startOfYear.subtract(const Duration(days: 1))))
        .toList();
    
    // Fill in the stats from session history
    for (final session in relevantSessions) {
      if (session.type == PomodoroType.work && 
          session.isCompleted && 
          session.endTime != null) {
        
        final sessionDate = session.endTime!;
        
        // Check if the session is in the current year
        if (sessionDate.year == currentYear) {
          final monthIndex = sessionDate.month - 1; // 0-indexed array
          
          final durationMinutes = session.durationSeconds ~/ 60;
          
          // Update statistics for the month
          yearStats[monthIndex] = yearStats[monthIndex].copyWith(
            completedPomodoros: yearStats[monthIndex].completedPomodoros + 1,
            totalFocusMinutes: yearStats[monthIndex].totalFocusMinutes + durationMinutes,
          );
        }
      }
    }
    
    return yearStats;
  }

  // Get daily breakdown for a specific day
  PomodoroStatistics getDailyStatistics(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    // Get all completed work sessions for the specified day
    final daySessions = _sessionHistory.where((session) => 
      session.type == PomodoroType.work && 
      session.isCompleted && 
      session.endTime != null &&
      DateTime(
        session.endTime!.year, 
        session.endTime!.month, 
        session.endTime!.day
      ) == targetDate
    ).toList();
    
    // Calculate statistics
    final completedPomodoros = daySessions.length;
    
    final totalFocusMinutes = daySessions.fold(0, (sum, session) {
      final durationMinutes = session.durationSeconds ~/ 60;
      return sum + durationMinutes;
    });
    
    // Calculate productivity score (example: total minutes / target minutes per day)
    // Assuming a target of 4 hours (240 minutes) for 100% productivity
    final targetMinutesPerDay = 240;
    final productivityScore = totalFocusMinutes / targetMinutesPerDay;
    final clampedScore = productivityScore > 1.0 ? 1.0 : productivityScore;
    
    return PomodoroStatistics(
      date: targetDate,
      completedPomodoros: completedPomodoros,
      totalFocusMinutes: totalFocusMinutes,
      productivityScore: clampedScore,
    );
  }

  // Group statistics by time of day (morning, afternoon, evening, night)
  Map<String, int> getDailyTimeDistribution(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    // Define time periods
    final morning = {'start': 5, 'end': 12}; // 5:00 AM - 11:59 AM
    final afternoon = {'start': 12, 'end': 17}; // 12:00 PM - 4:59 PM
    final evening = {'start': 17, 'end': 21}; // 5:00 PM - 8:59 PM
    final night = {'start': 21, 'end': 5}; // 9:00 PM - 4:59 AM
    
    final distribution = {
      'morning': 0,
      'afternoon': 0, 
      'evening': 0,
      'night': 0,
    };
    
    // Get all completed work sessions for the specified day
    final daySessions = _sessionHistory.where((session) => 
      session.type == PomodoroType.work && 
      session.isCompleted && 
      session.endTime != null &&
      DateTime(
        session.endTime!.year, 
        session.endTime!.month, 
        session.endTime!.day
      ) == targetDate
    ).toList();
    
    // Categorize sessions by time of day
    for (final session in daySessions) {
      final hour = session.endTime!.hour;
      
      if (hour >= morning['start']! && hour < morning['end']!) {
        distribution['morning'] = distribution['morning']! + (session.durationSeconds ~/ 60);
      } else if (hour >= afternoon['start']! && hour < afternoon['end']!) {
        distribution['afternoon'] = distribution['afternoon']! + (session.durationSeconds ~/ 60);
      } else if (hour >= evening['start']! && hour < evening['end']!) {
        distribution['evening'] = distribution['evening']! + (session.durationSeconds ~/ 60);
      } else {
        distribution['night'] = distribution['night']! + (session.durationSeconds ~/ 60);
      }
    }
    
    return distribution;
  }

  // Get most productive day of week based on all historical data
  Map<String, int> getProductivityByDayOfWeek() {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final productivityByDay = Map.fromIterables(dayNames, List.filled(7, 0));
    
    // Get all completed work sessions
    final workSessions = _sessionHistory.where((session) => 
      session.type == PomodoroType.work && 
      session.isCompleted && 
      session.endTime != null
    ).toList();
    
    // Group by day of week
    for (final session in workSessions) {
      final dayOfWeek = session.endTime!.weekday - 1; // 0 = Monday, 6 = Sunday
      final dayName = dayNames[dayOfWeek];
      final minutes = session.durationSeconds ~/ 60;
      
      productivityByDay[dayName] = productivityByDay[dayName]! + minutes;
    }
    
    return productivityByDay;
  }

  // Get average focus time per session
  double getAverageFocusTime() {
    final workSessions = _sessionHistory.where((session) => 
      session.type == PomodoroType.work && 
      session.isCompleted
    ).toList();
    
    if (workSessions.isEmpty) return 0.0;
    
    final totalMinutes = workSessions.fold(0, (sum, session) => 
      sum + (session.durationSeconds ~/ 60)
    );
    
    return totalMinutes / workSessions.length;
  }

  void _notifyListeners() {
    notifyListeners();
  }
}