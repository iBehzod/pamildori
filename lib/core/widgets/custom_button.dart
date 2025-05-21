import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height,
    this.width,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height ?? 54,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: textColor ?? theme.colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
            horizontal: AppConstants.paddingLarge,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: textColor ?? theme.colorScheme.onPrimary,
                  strokeWidth: 2.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 20),
                    const SizedBox(width: AppConstants.paddingSmall),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor ?? theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: AppConstants.paddingSmall),
                    Icon(suffixIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}