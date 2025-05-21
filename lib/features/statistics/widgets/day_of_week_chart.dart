import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/pomodoro_utils.dart';

class DayOfWeekChart extends StatelessWidget {
  final List<Map<String, dynamic>> dayOfWeekData;
  
  const DayOfWeekChart({
    super.key,
    required this.dayOfWeekData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate total minutes
    final int totalMinutes = dayOfWeekData.fold(
      0, 
      (sum, entry) => sum + (entry['value'] as int)
    );
    
    // Handle empty data case
    if (totalMinutes == 0 || dayOfWeekData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Productivity by Day',
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
                'No productivity data available',
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
                'Productivity by Day',
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
                      final item = dayOfWeekData[groupIndex];
                      return BarTooltipItem(
                        '${item['label']}\n${PomodoroUtils.formatMinutes(item['value'])}',
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
                        if (value < 0 || value >= dayOfWeekData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getAbbreviatedDayName(dayOfWeekData[value.toInt()]['label']),
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
                barGroups: _createBarGroups(theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(ThemeData theme) {
    return List.generate(dayOfWeekData.length, (index) {
      final data = dayOfWeekData[index];
      final value = data['value'] as int;
      // Get the day's productivity level to determine the color intensity
      final maxValue = dayOfWeekData.fold<int>(
          0, (max, entry) => (entry['value'] as int) > max ? (entry['value'] as int) : max);
      final double intensity = maxValue > 0 ? (value / maxValue) : 0;
      
      // Calculate bar color based on intensity
      Color barColor;
      if (data.containsKey('color')) {
        barColor = data['color'] as Color;
      } else {
        barColor = theme.colorScheme.primary.withOpacity(0.3 + (intensity * 0.7));
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
    final maxValue = dayOfWeekData.fold<int>(
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
  
  String _getAbbreviatedDayName(String dayName) {
    // Return the first 3 characters of the day name
    if (dayName.length > 3) {
      return dayName.substring(0, 3);
    }
    return dayName;
  }
} 