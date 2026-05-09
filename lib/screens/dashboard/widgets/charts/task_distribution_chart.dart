import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:task_app/core/theme/app_pallete.dart';

import 'package:task_app/models/task_model.dart';
import 'package:task_app/widgets/common/button/animated_toggle_button.dart';
import 'calendar_distribution.dart';

class ChartData {
  ChartData(this.period, this.todo, this.completed, this.overdue, this.date);

  final String period;
  final double todo;
  final double completed;
  final double overdue;
  final DateTime date;
}

enum ChartViewType { week, month }

class TaskDistributionChart extends StatefulWidget {
  final List<Task> tasks;
  final ChartViewType initialView;
  final bool showToggle;
  final Function(int, String?) navigationToTaskList;

  const TaskDistributionChart({
    super.key,
    required this.tasks,
    required this.navigationToTaskList,
    this.initialView = ChartViewType.week,
    this.showToggle = true,
  });

  @override
  State<TaskDistributionChart> createState() => _TaskDistributionChartState();
}

class _TaskDistributionChartState extends State<TaskDistributionChart>
    with TickerProviderStateMixin {
  late ChartViewType currentView;
  int _weekOffset = 0; // 0 = current week, -1 = previous week, +1 = next week
  late AnimationController _viewTransitionController;
  late Animation<double> _fadeAnimation;

  final Map<String, bool> _seriesVisibility = {
    'To Do': true,
    'In Progress': true,
    'Completed': true,
    'Overdue': true,
  };

  @override
  void initState() {
    super.initState();
    currentView = widget.initialView;

    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _viewTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    _viewTransitionController.forward();
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    super.dispose();
  }

  // Get start of calendar week (Monday)
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysFromMonday));
  }

  // Get current week with offset
  DateTime get _currentWeekStart {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    return weekStart.add(Duration(days: _weekOffset * 7));
  }

  List<ChartData> _getWeeklyChartData() {
    final weekStart = _currentWeekStart;
    List<ChartData> chartData = [];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayTasks =
          widget.tasks
              .where(
                (task) =>
                    task.dueDate.year == date.year &&
                    task.dueDate.month == date.month &&
                    task.dueDate.day == date.day,
              )
              .toList();

      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dateLabel = '${date.day}\n${dayNames[i]}';

      chartData.add(
        ChartData(
          dateLabel,
          dayTasks
              .where((t) => !t.isOverdue && t.status != TaskStatus.completed)
              .length
              .toDouble(),
          dayTasks
              .where((t) => t.status == TaskStatus.completed)
              .length
              .toDouble(),
          dayTasks.where((t) => t.isOverdue).length.toDouble(),
          date,
        ),
      );
    }

    return chartData;
  }

  String _getWeekRange() {
    final weekStart = _currentWeekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = intl.DateFormat('MMM dd');

    if (weekStart.month == weekEnd.month) {
      return '${formatter.format(weekStart)} - ${weekEnd.day}, ${weekEnd.year}';
    } else {
      return '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}';
    }
  }

  String _getTitle() {
    switch (currentView) {
      case ChartViewType.week:
        return 'Weekly Task Distribution';
      case ChartViewType.month:
        return 'Monthly Task Distribution';
    }
  }

  String _getSubtitle() {
    switch (currentView) {
      case ChartViewType.week:
        return _getWeekRange();
      case ChartViewType.month:
        final now = DateTime.now();
        return intl.DateFormat('MMMM yyyy').format(now);
    }
  }

  Widget _buildCustomLegend(ThemeData theme) {
    final legendItems = [
      {'name': 'To Do', 'color': Colors.blue},
      {'name': 'Completed', 'color': Colors.green},
      {'name': 'Overdue', 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.center,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children:
              legendItems.map((item) {
                final isVisible = _seriesVisibility[item['name']] ?? true;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _seriesVisibility[item['name'] as String] = !isVisible;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (item['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                isVisible
                                    ? item['color'] as Color
                                    : (item['color'] as Color).withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['name'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                isVisible
                                    ? (item['color'] as Color)
                                    : theme.disabledColor,
                            fontWeight:
                                isVisible ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // New method to check if there are any incomplete tasks in ANY previous weeks
  bool _hasAnyIncompleteTasksInPreviousWeeks() {
    final currentWeekStart = _getWeekStart(DateTime.now());
    return widget.tasks.any(
      (task) =>
          task.dueDate.isBefore(currentWeekStart) &&
          task.status != TaskStatus.completed,
    );
  }

  // New method to check if there are any incomplete tasks in ANY future weeks
  bool _hasAnyIncompleteTasksInFutureWeeks() {
    final currentWeekStart = _getWeekStart(DateTime.now());
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
    return widget.tasks.any(
      (task) =>
          task.dueDate.isAfter(currentWeekEnd) &&
          task.status != TaskStatus.completed,
    );
  }

  // Enhanced method to check for incomplete tasks in the direction of navigation
  bool _hasIncompleteTasksInDirection(bool isPrevious) {
    if (_weekOffset == 0) {
      return isPrevious
          ? _hasAnyIncompleteTasksInPreviousWeeks()
          : _hasAnyIncompleteTasksInFutureWeeks();
    } else if (_weekOffset < 0) {
      if (isPrevious) {
        final viewingWeekStart = _currentWeekStart;
        return widget.tasks.any(
          (task) =>
              task.dueDate.isBefore(viewingWeekStart) &&
              task.status != TaskStatus.completed,
        );
      } else {
        final viewingWeekEnd = _currentWeekStart.add(const Duration(days: 6));
        return widget.tasks.any(
          (task) =>
              task.dueDate.isAfter(viewingWeekEnd) &&
              task.status != TaskStatus.completed,
        );
      }
    } else {
      if (isPrevious) {
        final viewingWeekStart = _currentWeekStart;
        return widget.tasks.any(
          (task) =>
              task.dueDate.isBefore(viewingWeekStart) &&
              task.status != TaskStatus.completed,
        );
      } else {
        final viewingWeekEnd = _currentWeekStart.add(const Duration(days: 6));
        return widget.tasks.any(
          (task) =>
              task.dueDate.isAfter(viewingWeekEnd) &&
              task.status != TaskStatus.completed,
        );
      }
    }
  }

  Widget _buildWeekNavigation(ThemeData theme) {
    final hasPreviousIncompleteTasks = _hasIncompleteTasksInDirection(true);
    final hasNextIncompleteTasks = _hasIncompleteTasksInDirection(false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _weekOffset--;
                });
              },
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.primaryContainer,
              ),
              tooltip: 'Previous Week',
            ),
            if (hasPreviousIncompleteTasks)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Text(
          _weekOffset == 0
              ? 'This Week'
              : _weekOffset == -1
              ? 'Last Week'
              : _weekOffset == 1
              ? 'Next Week'
              : _weekOffset < 0
              ? '${_weekOffset.abs()} weeks ago'
              : '$_weekOffset weeks ahead',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _weekOffset++;
                });
              },
              icon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primaryContainer,
              ),
              tooltip: 'Next Week',
            ),
            if (hasNextIncompleteTasks)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData =
        currentView == ChartViewType.week
            ? _getWeeklyChartData()
            : <ChartData>[];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 5,
                height: currentView == ChartViewType.week ? 35 : 55,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              if (widget.showToggle)
                AnimatedToggleButton(
                  values: ["Week", "Month"],
                  onToggle: (value) async {
                    await _viewTransitionController.reverse();
                    setState(() {
                      currentView = ChartViewType.values[value];
                      if (currentView == ChartViewType.week) {
                        _weekOffset = 0; // Reset to current week
                      }
                    });
                    _viewTransitionController.forward();
                  },
                  theme: theme,
                ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 16),

          // Week Navigation (only for week view)
          if (currentView == ChartViewType.week) ...[
            _buildWeekNavigation(theme),
            const SizedBox(height: 16),
          ],

          // Legend (only for week view)
          if (currentView == ChartViewType.week) ...[
            _buildCustomLegend(theme),
            const SizedBox(height: 16),
          ],

          // Chart
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: currentView == ChartViewType.week ? 400 : 500,
              child:
                  currentView == ChartViewType.month
                      ? CalendarDistribution(
                        tasks: widget.tasks,
                        theme: theme,
                        navigationToTaskList: widget.navigationToTaskList,
                      )
                      : SfCartesianChart(
                        legend: const Legend(isVisible: false),
                        plotAreaBorderWidth: 0,
                        primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: theme.textTheme.bodySmall,
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: MajorGridLines(
                            width: 1,
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: theme.textTheme.bodySmall,
                          minimum: 0,
                          interval: 1,
                        ),
                        series: <CartesianSeries>[
                          if (_seriesVisibility['To Do'] ?? true)
                            StackedColumnSeries<ChartData, String>(
                              animationDuration: 300,
                              dataSource: chartData,
                              xValueMapper: (d, _) => d.period,
                              yValueMapper: (d, _) => d.todo,
                              name: 'To Do',
                              gradient: LinearGradient(
                                colors: [
                                  AppPallete.infoMain,
                                  AppPallete.infoMain.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),

                          if (_seriesVisibility['Completed'] ?? true)
                            StackedColumnSeries<ChartData, String>(
                              animationDuration: 300,

                              dataSource: chartData,
                              xValueMapper: (d, _) => d.period,
                              yValueMapper: (d, _) => d.completed,
                              name: 'Completed',
                              gradient: LinearGradient(
                                colors: [
                                  AppPallete.successMain,
                                  AppPallete.successMain.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          if (_seriesVisibility['Overdue'] ?? true)
                            StackedColumnSeries<ChartData, String>(
                              animationDuration: 300,
                              dataSource: chartData,
                              xValueMapper: (d, _) => d.period,
                              yValueMapper: (d, _) => d.overdue,
                              name: 'Overdue',
                              gradient: LinearGradient(
                                colors: [
                                  AppPallete.errorMain,
                                  AppPallete.errorMain.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                        ],
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          format: 'point.x: point.y tasks',
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
