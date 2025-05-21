import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class DurationPickerDialog extends StatefulWidget {
  final int initialValue;
  final String title;
  final int min;
  final int max;
  
  const DurationPickerDialog({
    super.key,
    required this.initialValue,
    required this.title,
    required this.min,
    required this.max,
  });

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  late int _value;
  
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > widget.min ? _decreaseValue : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSmall,
                  horizontal: AppConstants.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _value.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text('min'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              IconButton(
                onPressed: _value < widget.max ? _increaseValue : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Slider
          Slider(
            value: _value.toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            label: '${_value.toString()} min',
            onChanged: (value) {
              setState(() {
                _value = value.round();
              });
            },
          ),
          
          // Preset values
          const SizedBox(height: AppConstants.paddingSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPresetButtons(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_value);
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
  
  List<Widget> _buildPresetButtons() {
    final List<int> presets = [];
    
    // For work duration and long breaks
    if (widget.max >= 30) {
      presets.addAll([5, 15, 20, 25, 30, 45, 60]);
    } 
    // For short breaks
    else {
      presets.addAll([1, 3, 5, 10, 15]);
    }
    
    // Filter presets that are within the range
    final validPresets = presets
        .where((preset) => preset >= widget.min && preset <= widget.max)
        .toList();
    
    return validPresets.map((preset) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingXSmall / 2,
        ),
        child: ActionChip(
          label: Text('$preset min'),
          backgroundColor: _value == preset
              ? Theme.of(context).colorScheme.primary
              : null,
          labelStyle: TextStyle(
            color: _value == preset
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
          onPressed: () {
            setState(() {
              _value = preset;
            });
          },
        ),
      );
    }).toList();
  }
  
  void _increaseValue() {
    setState(() {
      _value = _value < widget.max ? _value + 1 : _value;
    });
  }
  
  void _decreaseValue() {
    setState(() {
      _value = _value > widget.min ? _value - 1 : _value;
    });
  }
}