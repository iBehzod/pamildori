import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pamildori/core/utils/pomodoro_utils.dart';

class TimeDistributionChart extends StatelessWidget {
  final List<Map<String, dynamic>> timeDistributionData;
  
  const TimeDistributionChart({
    super.key,
    required this.timeDistributionData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate total minutes
    final int totalMinutes = timeDistributionData.fold(
      0, 
      (sum, entry) => sum + (entry['value'] as int)
    );
    
    // Handle empty data case
    if (totalMinutes == 0 || timeDistributionData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Time Distribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.pie_chart,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No time distribution data available',
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

    // Special case: Only one segment with data
    if (timeDistributionData.length == 1) {
      final entry = timeDistributionData.first;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Time Distribution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry['color'] as Color? ?? theme.colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    '100%',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry['color'] as Color? ?? theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry['label'] as String,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    PomodoroUtils.formatMinutes(entry['value'] as int),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
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
                'Time Distribution',
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
          height: 220,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PieChart(
                  PieChartData(
                    sections: _createSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(
                      touchCallback: (flTouchEvent, pieTouchResponse) {
                        // Touch handling if needed
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildLegendItems(theme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createSections() {
    return List.generate(timeDistributionData.length, (index) {
      final item = timeDistributionData[index];
      final value = item['value'] as int;
      final color = item['color'] as Color? ?? Colors.blue;
      
      // Calculate percentage
      final totalValue = timeDistributionData.fold<int>(
        0, (sum, entry) => sum + (entry['value'] as int));
      final double percentage = totalValue > 0 ? value / totalValue * 100 : 0;
      
      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildLegendItems(ThemeData theme) {
    // Sort items by value in descending order
    final sortedItems = List<Map<String, dynamic>>.from(timeDistributionData)
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
    
    // Calculate total for percentages
    final totalValue = timeDistributionData.fold<int>(
      0, (sum, entry) => sum + (entry['value'] as int));
    
    return sortedItems.map((item) {
      final label = item['label'] as String;
      final value = item['value'] as int;
      final color = item['color'] as Color? ?? Colors.blue;
      
      // Calculate percentage
      final double percentage = totalValue > 0 ? value / totalValue * 100 : 0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
} 