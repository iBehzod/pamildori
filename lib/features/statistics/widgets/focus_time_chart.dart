import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/pomodoro_statistics.dart';
import '../../../core/utils/pomodoro_utils.dart';

class FocusTimeChart extends StatelessWidget {
  final List<Map<String, dynamic>> focusTimeData;
  final String timeFrame;

  const FocusTimeChart({
    super.key,
    required this.focusTimeData,
    required this.timeFrame,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate total minutes
    final int totalMinutes = focusTimeData.fold(
      0, 
      (sum, entry) => sum + (entry['value'] as int)
    );
    
    // Handle empty data case
    if (totalMinutes == 0 || focusTimeData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Focus Time',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.bar_chart,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No focus time data available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Time Distribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                PomodoroUtils.formatMinutes(totalMinutes),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 || groupIndex >= focusTimeData.length) {
                        return null;
                      }
                      final item = focusTimeData[groupIndex];
                      return BarTooltipItem(
                        '${item['label']}\n${PomodoroUtils.formatMinutes(item['value'] as int)}',
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= focusTimeData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getXAxisLabel(focusTimeData[index]['label'] as String),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _getYInterval(),
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _formatTimeLabel(value.toInt()),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _createBarGroups(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(BuildContext context) {
    if (focusTimeData.isEmpty) return [];
    
    // Get maximum value for color intensity
    final maxValue = focusTimeData.fold<int>(
        0, (max, entry) => (entry['value'] as int) > max ? (entry['value'] as int) : max);
    
    return List.generate(focusTimeData.length, (index) {
      final entry = focusTimeData[index];
      final value = entry['value'] as int;
      
      // Calculate intensity based on value
      final double intensity = maxValue > 0 ? (value / maxValue) : 0;
      
      // Determine bar color - use provided color or calculate based on intensity
      Color barColor;
      if (entry.containsKey('color') && entry['color'] != null) {
        barColor = entry['color'] as Color;
      } else {
        // Default to primary color with intensity-based opacity
        barColor = Theme.of(context).colorScheme.primary.withOpacity(0.3 + (intensity * 0.7));
      }
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (focusTimeData.isEmpty) return 10.0; // Return a default if no data
    
    final maxValue = focusTimeData.fold<int>(
        0, (max, entry) => (entry['value'] as int) > max ? (entry['value'] as int) : max);
    
    // Add some padding to the top
    final paddedMax = (maxValue * 1.2).toInt();
    
    // Round to a nice number based on the magnitude
    if (paddedMax <= 60) {  // Up to 1 hour
      return ((paddedMax / 10).ceil() * 10).toDouble();
    } else if (paddedMax <= 180) {  // Up to 3 hours
      return ((paddedMax / 30).ceil() * 30).toDouble();
    } else if (paddedMax <= 360) {  // Up to 6 hours
      return ((paddedMax / 60).ceil() * 60).toDouble();
    } else {  // More than 6 hours
      return ((paddedMax / 120).ceil() * 120).toDouble();
    }
  }
  
  double _getYInterval() {
    if (focusTimeData.isEmpty) return 5.0; // Default interval for empty data
    
    final maxY = _getMaxY();
    
    // Choose an appropriate interval based on the max value
    if (maxY <= 60) {  // Up to 1 hour
      return 10;
    } else if (maxY <= 180) {  // Up to 3 hours
      return 30;
    } else if (maxY <= 360) {  // Up to 6 hours
      return 60;
    } else {  // More than 6 hours
      return 120;
    }
  }
  
  String _formatTimeLabel(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      return '${minutes ~/ 60}h';
    }
  }
  
  String _getXAxisLabel(String label) {
    if (label.isEmpty) return '';
    
    switch (timeFrame) {
      case 'daily':
        // For daily, show hours like "12AM", "3PM", etc.
        return label;
      case 'weekly':
        // For weekly, abbreviate day names like "Mon", "Tue", etc.
        return label.length > 3 ? label.substring(0, 3) : label;
      case 'monthly':
        // For monthly, show dates like "1", "15", etc.
        return label;
      case 'yearly':
        // For yearly, abbreviate month names like "Jan", "Feb", etc.
        return label.length > 3 ? label.substring(0, 3) : label;
      default:
        return label;
    }
  }
} 