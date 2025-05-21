import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/pomodoro_service.dart';
import 'services/sound_service.dart';
import 'services/notification_service.dart';
import 'services/task_service.dart';
import 'services/streak_service.dart';
import 'features/auth/screens/splash_screen.dart';
import 'models/settings_model.dart'; // Import for ThemeNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize storage service
  final storageService = await StorageService.init();
  
  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatefulWidget {
  final StorageService storageService;
  
  const MyApp({super.key, required this.storageService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthService _authService;
  late PomodoroService _pomodoroService;
  late SoundService _soundService;
  late NotificationService _notificationService;
  late TaskService _taskService;
  late StreakService _streakService;
  bool _darkMode = false;
  String _accentColor = 'tomato';
  
  @override
  void initState() {
    super.initState();
    // Initialize services
    _authService = AuthService(widget.storageService);
    _soundService = SoundService();
    _notificationService = NotificationService();
    _taskService = TaskService(widget.storageService);
    _streakService = StreakService(widget.storageService);
    _pomodoroService = PomodoroService(widget.storageService, _taskService);
    
    // Initialize services that require async setup
    _initializeServices();
    
    // Load user settings
    _loadThemeSettings();
  }
  
  Future<void> _initializeServices() async {
    // Initialize sound service
    await _soundService.init();
    
    // Initialize notification service
    await _notificationService.init();
    
    // Connect services
    _pomodoroService.setSoundService(_soundService);
    _pomodoroService.setNotificationService(_notificationService);
    _pomodoroService.setStreakService(_streakService);
    
    // Set current user for user-specific services
    final authData = widget.storageService.getAuthData();
    if (authData != null) {
      _taskService.setCurrentUser(authData.user.id);
      _streakService.setCurrentUser(authData.user.id);
    }
  }
  
  @override
  void dispose() {
    _soundService.dispose();
    super.dispose();
  }
  
  Future<void> _loadThemeSettings() async {
    final authData = widget.storageService.getAuthData();
    if (authData != null) {
      final userSettings = widget.storageService.getUserSettings(authData.user.id);
      if (userSettings != null) {
        setState(() {
          _darkMode = userSettings.pomodoroSettings.darkMode;
          _accentColor = userSettings.pomodoroSettings.accentColor;
        });
      }
    }
  }
  
  Future<void> _updateThemeSettings(bool darkMode, String accentColor) async {
    final authData = widget.storageService.getAuthData();
    if (authData != null) {
      final userId = authData.user.id;
      final userSettings = widget.storageService.getUserSettings(userId) ?? 
          UserSettings(userId: userId);
          
      final pomodoroSettings = userSettings.pomodoroSettings.copyWith(
        darkMode: darkMode,
        accentColor: accentColor,
      );
      
      final updatedSettings = UserSettings(
        userId: userId,
        pomodoroSettings: pomodoroSettings,
        syncEnabled: userSettings.syncEnabled,
        syncFrequency: userSettings.syncFrequency,
        enabledFeatures: userSettings.enabledFeatures,
      );
      
      await widget.storageService.saveUserSettings(updatedSettings);
    }
    
    setState(() {
      _darkMode = darkMode;
      _accentColor = accentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = _darkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    final theme = AppTheme.getThemeWithAccentColor(baseTheme, _accentColor);

    // Create ThemeNotifier instance outside of the provider
    final themeNotifier = ThemeNotifier(
      darkMode: _darkMode,
      accentColor: _accentColor,
    );
    
    // Add listener to update theme settings when the notifier changes
    themeNotifier.addListener(() {
      _updateThemeSettings(
        themeNotifier.darkMode,
        themeNotifier.accentColor
      );
    });

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: widget.storageService),
        Provider<AuthService>.value(value: _authService),
        Provider<SoundService>.value(value: _soundService),
        Provider<NotificationService>.value(value: _notificationService),
        ChangeNotifierProvider<TaskService>.value(value: _taskService),
        ChangeNotifierProvider<StreakService>.value(value: _streakService),
        ChangeNotifierProvider<PomodoroService>.value(value: _pomodoroService),
        // Provide the already-created ThemeNotifier instance
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
