import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  
  const SettingsSection({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(
        top: AppConstants.paddingMedium,
        bottom: AppConstants.paddingXSmall,
        left: AppConstants.paddingSmall,
        right: AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}