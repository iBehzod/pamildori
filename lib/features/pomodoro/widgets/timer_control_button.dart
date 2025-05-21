import 'package:flutter/material.dart';

class TimerControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final double iconSize;
  final String? tooltip;

  const TimerControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 60.0,
    this.iconSize = 30.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: _buildButton(context),
          )
        : _buildButton(context);
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color?.withOpacity(0.2) ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}