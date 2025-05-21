import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/pomodoro_model.dart';
import '../../../models/pomodoro_statistics.dart';
import '../../../services/pomodoro_service.dart';
import '../../../services/streak_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/focus_time_chart.dart';
import '../widgets/time_distribution_chart.dart';
import '../widgets/day_of_week_chart.dart';
import '../../../core/utils/pomodoro_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoroService = Provider.of<PomodoroService>(context);
    final streakService = Provider.of<StreakService>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and streak info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Streak card
                  const StreakCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Summary stats
                  _buildSummaryStats(context, pomodoroService),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyTab(context, pomodoroService),
                  _buildWeeklyTab(context, pomodoroService),
                  _buildMonthlyTab(context, pomodoroService),
                  _buildYearlyTab(context, pomodoroService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryStats(BuildContext context, PomodoroService pomodoroService) {
    final completedSessions = pomodoroService.completedWorkSessions;
    final totalFocusMinutes = pomodoroService.getTotalFocusMinutesToday();
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Completed Sessions',
                  '$completedSessions',
                  Icons.check_circle_outline,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Focus Time',
                  PomodoroUtils.formatMinutes(totalFocusMinutes),
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, 
    String label, 
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label, 
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              value, 
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDailyTab(BuildContext context, PomodoroService pomodoroService) {
    final today = DateTime.now();
    final dailyStats = pomodoroService.getDailyStatistics(today);
    final dailyTimeDistribution = _convertTimeDistribution(pomodoroService.getDailyTimeDistribution(today));
    final averageFocusTime = pomodoroService.getAverageFocusTime();
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Distribution Chart
            Card(
              margin: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 280,
                child: TimeDistributionChart(timeDistributionData: dailyTimeDistribution),
              ),
            ),
            
            // Average focus time per session
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Focus Time per Session',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: theme.colorScheme.primary,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${averageFocusTime.toStringAsFixed(1)} min',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyTab(BuildContext context, PomodoroService pomodoroService) {
    final weeklyStats = _convertStatisticsList(pomodoroService.getWeeklyStatistics());
    final productivityByDay = _convertDayOfWeekData(pomodoroService.getProductivityByDayOfWeek());
    
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Weekly Focus Time Chart
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 280,
                      child: FocusTimeChart(
                        focusTimeData: weeklyStats,
                        timeFrame: 'weekly',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Day of Week Productivity Chart
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 280,
                child: DayOfWeekChart(dayOfWeekData: productivityByDay),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthlyTab(BuildContext context, PomodoroService pomodoroService) {
    final monthlyStatsRaw = pomodoroService.getMonthlyStatistics();
    final monthlyStats = _convertStatisticsList(monthlyStatsRaw);
    final totalMonthlyMinutes = monthlyStatsRaw.fold(0, (sum, stat) => sum + stat.totalFocusMinutes);
    final totalMonthlySessions = monthlyStatsRaw.fold(0, (sum, stat) => sum + stat.completedPomodoros);
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Monthly summary
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                PomodoroUtils.formatMinutes(totalMonthlyMinutes),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Focus Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$totalMonthlySessions',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed Sessions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Monthly Focus Time Chart
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 280,
                      child: FocusTimeChart(
                        focusTimeData: monthlyStats,
                        timeFrame: 'monthly',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildYearlyTab(BuildContext context, PomodoroService pomodoroService) {
    final yearlyStatsRaw = pomodoroService.getYearlyStatistics();
    final yearlyStats = _convertStatisticsList(yearlyStatsRaw);
    final totalYearlyMinutes = yearlyStatsRaw.fold(0, (sum, stat) => sum + stat.totalFocusMinutes);
    final totalYearlySessions = yearlyStatsRaw.fold(0, (sum, stat) => sum + stat.completedPomodoros);
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Yearly summary
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yearly Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                PomodoroUtils.formatMinutes(totalYearlyMinutes),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Focus Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$totalYearlySessions',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed Sessions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Yearly Focus Time Chart
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 16.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 280,
                      child: FocusTimeChart(
                        focusTimeData: yearlyStats,
                        timeFrame: 'yearly',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  // Helper method to convert PomodoroStatistics list to the format required by FocusTimeChart
  List<Map<String, dynamic>> _convertStatisticsList(List<PomodoroStatistics> statistics) {
    final List<Map<String, dynamic>> result = [];
    
    if (statistics.isEmpty) {
      return result; // Return empty list if there are no statistics
    }
    
    // Check if it's yearly data (12 months)
    final bool isYearlyData = statistics.length == 12;
    
    // Prepare month and day names
    final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // For yearly data, use fixed month labels
    if (isYearlyData) {
      for (int i = 0; i < statistics.length && i < 12; i++) {
        final stat = statistics[i];
        if (stat.date == null) continue;
        
        // Use different colors for different months
        final Color color = Colors.blue.withOpacity(0.5 + (i / 24)); // Vary opacity slightly
        
        result.add({
          'label': monthNames[i], // Use fixed month name from index
          'value': stat.totalFocusMinutes,
          'color': color,
        });
      }
      return result;
    }
    
    // Get date format based on statistics granularity (weekly or monthly)
    String getLabel(DateTime date, int index) {
      if (statistics.length <= 7) {
        // Weekly format - use day names
        return index < dayNames.length ? dayNames[index] : '?';
      } else {
        // Monthly format - use day of month
        return '${date.day}';
      }
    }
    
    // For weekly or monthly data
    for (int i = 0; i < statistics.length; i++) {
      final stat = statistics[i];
      
      // Ensure we have valid values
      if (stat.date == null) continue;
      
      final Color color = Colors.blue.withOpacity(0.7);
      
      result.add({
        'label': getLabel(stat.date, i),
        'value': stat.totalFocusMinutes,
        'color': color,
      });
    }
    
    return result;
  }
  
  // Helper method to convert time distribution data
  List<Map<String, dynamic>> _convertTimeDistribution(Map<String, int> distribution) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> result = [];
    
    final Map<String, Color> colors = {
      'morning': Colors.orange,
      'afternoon': Colors.blue,
      'evening': Colors.purple,
      'night': Colors.indigo,
    };
    
    final Map<String, String> labels = {
      'morning': 'Morning (5AM-12PM)',
      'afternoon': 'Afternoon (12PM-5PM)',
      'evening': 'Evening (5PM-9PM)',
      'night': 'Night (9PM-5AM)',
    };
    
    distribution.forEach((key, value) {
      if (value > 0) {
        result.add({
          'label': labels[key] ?? key,
          'value': value,
          'color': colors[key] ?? theme.colorScheme.primary,
        });
      }
    });
    
    return result;
  }
  
  // Helper method to convert day of week productivity data
  List<Map<String, dynamic>> _convertDayOfWeekData(Map<String, int> productivityByDay) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> result = [];
    
    // Ensure days are in order (Monday to Sunday)
    final List<String> dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final day in dayOrder) {
      final value = productivityByDay[day] ?? 0;
      result.add({
        'label': day,
        'value': value,
        'color': theme.colorScheme.primary,
      });
    }
    
    return result;
  }
}