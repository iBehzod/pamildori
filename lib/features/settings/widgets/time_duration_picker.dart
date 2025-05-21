import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class TimeDurationPicker extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const TimeDurationPicker({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  State<TimeDurationPicker> createState() => _TimeDurationPickerState();
}

class _TimeDurationPickerState extends State<TimeDurationPicker> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Simple time selector with +/- buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > widget.minValue ? _decreaseValue : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
              ),
              const SizedBox(width: AppConstants.paddingLarge),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    '$_value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingLarge),
              IconButton(
                onPressed: _value < widget.maxValue ? _increaseValue : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(_value);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _increaseValue() {
    setState(() {
      _value = _value < widget.maxValue ? _value + 1 : _value;
    });
    widget.onChanged(_value);
  }

  void _decreaseValue() {
    setState(() {
      _value = _value > widget.minValue ? _value - 1 : _value;
    });
    widget.onChanged(_value);
  }
}