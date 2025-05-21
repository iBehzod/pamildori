import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pomodoro_utils.dart';
import '../../../models/pomodoro_model.dart';
import '../../../models/settings_model.dart';

class SessionInfoCard extends StatelessWidget {
  final PomodoroType sessionType;
  final int completedSessions;
  final PomodoroSettings settings;
  
  const SessionInfoCard({
    super.key,
    required this.sessionType,
    required this.completedSessions,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWorkSession = sessionType == PomodoroType.work;
    final sessionName = PomodoroUtils.getNameForSessionType(sessionType);
    final sessionColor = PomodoroUtils.getColorForSessionType(sessionType, theme);
    
    // For work sessions, show the count (e.g., "1/4")
    // For breaks, show the type (short or long)
    final subtitle = isWorkSession
        ? 'Session ${(completedSessions % settings.longBreakInterval) + 1}/${settings.longBreakInterval}'
        : sessionType == PomodoroType.shortBreak
            ? 'Take a short break'
            : 'Take a long break';
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        side: BorderSide(
          color: sessionColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        child: Column(
          children: [
            // Session name and icon
            Row(
              children: [
                Icon(
                  isWorkSession 
                      ? Icons.work_outline
                      : Icons.coffee_outlined,
                  color: sessionColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  sessionName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: sessionColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: AppConstants.paddingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: sessionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: sessionColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}