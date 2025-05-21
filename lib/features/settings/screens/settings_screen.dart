import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/settings_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/pomodoro_service.dart';
import '../../../services/streak_service.dart';
import '../widgets/color_picker_item.dart';
import '../widgets/settings_tile.dart';
import '../widgets/time_duration_picker.dart';
import '../../auth/screens/sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PomodoroSettings _settings;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default settings to avoid late initialization error
    _settings = PomodoroSettings();
    
    // Delay initialization to avoid accessing context before it's ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSettings();
    });
  }
  
  void _initializeSettings() {
    // Safely get services from provider
    final pomodoroService = Provider.of<PomodoroService>(context, listen: false);
    
    if (mounted) {
      setState(() {
        _settings = pomodoroService.settings;
        _isInitialized = true;
      });
    }

    try {
      // Try to get ThemeNotifier, but handle if it's not available
      if (mounted) {
        // Safely access ThemeNotifier with a null check
        final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
        setState(() {
          _isDarkMode = themeNotifier.darkMode;
        });
      }
    } catch (e) {
      // If ThemeNotifier is not available, use settings values
      if (mounted) {
        setState(() {
          _isDarkMode = _settings.darkMode;
        });
      }
    }
  }

  void _updateSettings() {
    final pomodoroService = Provider.of<PomodoroService>(context, listen: false);
    pomodoroService.updateSettings(_settings);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(SuccessMessages.settingsSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.isAuthenticated;
    final streakService = Provider.of<StreakService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSection('Timer Settings', [
                  _buildDurationSetting(
                    'Work Duration',
                    _settings.workDurationMinutes,
                    (value) {
                      setState(() {
                        _settings = _settings.copyWith(workDurationMinutes: value);
                      });
                    },
                    Icons.work_outline, // Better work icon
                  ),
                  _buildDurationSetting(
                    'Short Break Duration',
                    _settings.shortBreakDurationMinutes,
                    (value) {
                      setState(() {
                        _settings = _settings.copyWith(shortBreakDurationMinutes: value);
                      });
                    },
                    Icons.coffee_outlined, // Coffee break icon
                  ),
                  _buildDurationSetting(
                    'Long Break Duration',
                    _settings.longBreakDurationMinutes,
                    (value) {
                      setState(() {
                        _settings = _settings.copyWith(longBreakDurationMinutes: value);
                      });
                    },
                    Icons.weekend_outlined, // Relaxation icon for long break
                  ),
                  _buildDurationSetting(
                    'Long Break Interval',
                    _settings.longBreakInterval,
                    (value) {
                      setState(() {
                        _settings = _settings.copyWith(longBreakInterval: value);
                      });
                    },
                    Icons.repeat,
                    minValue: 2,
                    maxValue: 10,
                  ),
                ]),
                _buildSection('Behavior', [
                  SettingsTile(
                    title: 'Auto-start Breaks',
                    subtitle: 'Automatically start breaks after work sessions',
                    leading: const Icon(Icons.play_circle_outline),
                    trailing: Switch(
                      value: _settings.autoStartBreaks,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(autoStartBreaks: value);
                        });
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Auto-start Work',
                    subtitle: 'Automatically start work sessions after breaks',
                    leading: const Icon(Icons.timer_outlined),
                    trailing: Switch(
                      value: _settings.autoStartPomodoros,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(autoStartPomodoros: value);
                        });
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Show Notifications',
                    subtitle: 'Display notifications when a timer completes',
                    leading: const Icon(Icons.notifications_none_outlined),
                    trailing: Switch(
                      value: _settings.showNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(showNotifications: value);
                        });
                      },
                    ),
                  ),
                ]),
                _buildSection('Streak', [
                  SettingsTile(
                    title: 'Minimum Daily Focus',
                    subtitle: '${streakService.minimumMinutesPerDay} minutes per day required',
                    leading: const Icon(Icons.local_fire_department_outlined),
                    onTap: () => _showStreakSettingsDialog(context, streakService),
                  ),
                ]),
                _buildSection('Appearance', [
                  SettingsTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    leading: const Icon(Icons.dark_mode_outlined),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                          Provider.of<ThemeNotifier>(context, listen: false).setDarkMode(value);
                          _settings = _settings.copyWith(darkMode: value);
                        });
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Accent Color',
                    subtitle: 'Choose the main color for the app',
                    leading: const Icon(Icons.color_lens_outlined),
                    trailing: Container(width: 0), // Empty container for spacing
                    onTap: () => _showColorPicker(context),
                  ),
                  SettingsTile(
                    title: 'Sound',
                    subtitle: 'Play sounds when a timer completes',
                    leading: const Icon(Icons.volume_up_outlined),
                    trailing: Switch(
                      value: _settings.playSound,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(playSound: value);
                        });
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Vibration',
                    subtitle: 'Vibrate when a timer completes',
                    leading: const Icon(Icons.vibration_outlined),
                    trailing: Switch(
                      value: _settings.vibrate,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(vibrate: value);
                        });
                      },
                    ),
                  ),
                ]),
                _buildSection('Account', [
                  SettingsTile(
                    title: isAuthenticated ? 'Sign Out' : 'Sign In',
                    subtitle: isAuthenticated
                        ? 'Sign out from your account'
                        : 'Sign in to sync your data across devices',
                    leading: Icon(
                      isAuthenticated ? Icons.logout_outlined : Icons.login_outlined,
                    ),
                    onTap: () => _handleAuthAction(context, authService, isAuthenticated),
                  ),
                ]),
                const SizedBox(height: AppConstants.paddingXLarge),
                Center(
                  child: Text(
                    'Pamildori v${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
          // Persistent save button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _updateSettings();
                  Navigator.of(context).pop(); // Return to previous screen after saving
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingLarge,
            bottom: AppConstants.paddingSmall,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDurationSetting(
    String title,
    int value,
    ValueChanged<int> onChanged,
    IconData icon, {
    int minValue = 1,
    int maxValue = 60,
  }) {
    return SettingsTile(
      title: title,
      subtitle: '$value minutes',
      leading: Icon(icon),
      onTap: () => _showDurationPicker(
        context,
        title,
        value,
        onChanged,
        minValue,
        maxValue,
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context,
    String title,
    int currentValue,
    ValueChanged<int> onChanged,
    int minValue,
    int maxValue,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TimeDurationPicker(
          title: title,
          initialValue: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
        );
      },
    );
  }

  void _showColorPicker(BuildContext context) {
    final colors = ['tomato', 'blue', 'green', 'purple'];
    final colorNames = ['Tomato', 'Blue', 'Green', 'Purple'];
    final currentColor = _settings.accentColor.toLowerCase();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Accent Color',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  // Compare with the actual current color value
                  final isSelected = currentColor == colors[index].toLowerCase();
                  
                  return ColorPickerItem(
                    colorName: colors[index],
                    isSelected: isSelected,
                    label: colorNames[index],
                    onTap: () {
                      setState(() {
                        _settings = _settings.copyWith(accentColor: colors[index]);
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setAccentColor(colors[index]);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAuthAction(
    BuildContext context,
    AuthService authService,
    bool isAuthenticated,
  ) async {
    if (isAuthenticated) {
      // Get all required services
      final pomodoroService = Provider.of<PomodoroService>(context, listen: false);
      
      // Sign out logic
      await authService.signOut();
      
      // Reset pomodoro service state
      pomodoroService.resetTimer();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
        
        // Navigate to sign in screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    } else {
      // Navigate to sign in page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }
  
  void _showStreakSettingsDialog(BuildContext context, StreakService streakService) {
    final currentMinutes = streakService.minimumMinutesPerDay;
    int selectedMinutes = currentMinutes;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Minimum Focus Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set the minimum number of minutes you need to focus each day to maintain your streak.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: selectedMinutes > 5
                          ? () => setState(() => selectedMinutes -= 5)
                          : null,
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        '$selectedMinutes min',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: selectedMinutes < 120
                          ? () => setState(() => selectedMinutes += 5)
                          : null,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              streakService.setMinimumMinutesPerDay(selectedMinutes);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}