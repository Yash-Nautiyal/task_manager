import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';
import 'task_overlay.dart';
import 'calendar_indicator.dart';

class CalendarDistribution extends StatefulWidget {
  final List<Task> tasks;
  final ThemeData theme;
  final Function(int, String?) navigationToTaskList;

  const CalendarDistribution({
    super.key,
    required this.tasks,
    required this.theme,
    required this.navigationToTaskList,
  });

  @override
  State<CalendarDistribution> createState() => _CalendarDistributionState();
}

class _CalendarDistributionState extends State<CalendarDistribution>
    with TickerProviderStateMixin {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late final ValueNotifier<List<Task>> _selectedTasks;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _indicatorAnimationController;
  late AnimationController _taskOverlayAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showTaskOverlay = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay!));

    // Only keep indicator animation controller
    _indicatorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Task overlay animation controller
    _taskOverlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _taskOverlayAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taskOverlayAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _indicatorAnimationController.forward();

    // Show overlay if there are tasks for today
    if (_selectedTasks.value.isNotEmpty) {
      _showTaskOverlay = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _taskOverlayAnimationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    _indicatorAnimationController.dispose();
    _taskOverlayAnimationController.dispose();
    super.dispose();
  }

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      return isSameDay(task.dueDate, day);
    }).toList();
  }

  void _showTaskOverlayWithAnimation() {
    setState(() {
      _showTaskOverlay = true;
    });
    _taskOverlayAnimationController.forward();
  }

  void _hideTaskOverlay() {
    _taskOverlayAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showTaskOverlay = false;
        });
      }
    });
  }

  Widget _buildTaskIndicators(DateTime day) {
    final tasks = _getTasksForDay(day);
    return CalendarIndicator(
      day: day,
      tasks: tasks,
      theme: widget.theme,
      animation: _indicatorAnimationController,
    );
  }

  Widget _buildModernLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: widget.theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasIncompleteTasks(DateTime month) {
    final previousMonthTasks = widget.tasks.where(
      (task) =>
          (task.dueDate.year < month.year ||
              (task.dueDate.year == month.year &&
                  task.dueDate.month < month.month)) &&
          task.status != TaskStatus.completed,
    );
    return previousMonthTasks.isNotEmpty;
  }

  bool _hasIncompleteNextTasks(DateTime month) {
    return widget.tasks.any((task) {
      final d = task.dueDate;
      final isAfterMonth =
          (d.year > month.year) ||
          (d.year == month.year && d.month > month.month);
      return isAfterMonth && task.status != TaskStatus.completed;
    });
  }

  Widget _buildTaskOverlay() {
    return AnimatedBuilder(
      animation: _taskOverlayAnimationController,
      builder: (context, child) {
        return TaskOverlay(
          theme: widget.theme,
          selectedDay: _selectedDay!,
          tasks: _selectedTasks.value,
          onClose: _hideTaskOverlay,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
          navigateToTaskList: widget.navigationToTaskList,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close overlay when tapping anywhere outside
        if (_showTaskOverlay) {
          _hideTaskOverlay();
        }
      },
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Legend at the top
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildModernLegendItem('To Do', Colors.blue),
                    _buildModernLegendItem('In Progress', Colors.orange),
                    _buildModernLegendItem('Completed', Colors.green),
                    _buildModernLegendItem('Overdue', AppPallete.errorMain),
                  ],
                ),
              ),

              // Modern divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      widget.theme.colorScheme.outline.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Calendar
              Flexible(
                child: TableCalendar<Task>(
                  shouldFillViewport: true,
                  sixWeekMonthsEnforced: true,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,

                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Stack(
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          color: widget.theme.colorScheme.primaryContainer,
                          size: 28,
                        ),
                        if (_hasIncompleteTasks(_focusedDay)) // past
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppPallete.errorMain,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    rightChevronIcon: Stack(
                      children: [
                        Icon(
                          Icons.chevron_right_rounded,
                          color: widget.theme.colorScheme.primaryContainer,
                          size: 28,
                        ),
                        if (_hasIncompleteNextTasks(_focusedDay)) // future
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppPallete.errorMain,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    titleTextStyle: widget.theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: widget.theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.dividerColor,
                    ),
                    weekendStyle: widget.theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.error.withAlpha(180),
                    ),
                  ),

                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.all(4),
                    cellPadding: const EdgeInsets.all(0),
                    defaultTextStyle: widget.theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                    weekendTextStyle: widget.theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                    todayDecoration: BoxDecoration(
                      color: widget.theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.theme.colorScheme.primary.withOpacity(
                          0.5,
                        ),
                        width: 1,
                      ),
                    ),
                    todayTextStyle: widget.theme.textTheme.bodyMedium!.copyWith(
                      color: widget.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: widget.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _selectedTasks.value = _getTasksForDay(selectedDay);

                    // Show overlay only if there are tasks
                    if (_selectedTasks.value.isNotEmpty) {
                      _showTaskOverlayWithAnimation();
                    } else if (_showTaskOverlay) {
                      _hideTaskOverlay();
                    }
                  },

                  onPageChanged: (focusedDay) {
                    _indicatorAnimationController.reset();
                    _indicatorAnimationController.forward();

                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },

                  eventLoader: (day) => _getTasksForDay(day),

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, tasks) {
                      return _buildTaskIndicators(day);
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      final dayTasks =
                          widget.tasks
                              .where(
                                (t) =>
                                    t.dueDate.year == day.year &&
                                    t.dueDate.month == day.month &&
                                    t.dueDate.day == day.day,
                              )
                              .toList();

                      if (dayTasks.isEmpty) {
                        return Center(child: Text('${day.day}'));
                      }

                      Color borderColor;

                      if (dayTasks.any((t) => t.status == TaskStatus.overdue)) {
                        borderColor = AppPallete.errorMain;
                      } else if (dayTasks.any(
                        (t) => t.status == TaskStatus.todo,
                      )) {
                        borderColor = AppPallete.infoMain;
                      } else {
                        borderColor = AppPallete.successMain;
                      }

                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: borderColor.withAlpha(200),
                            width: 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Task Overlay
          if (_showTaskOverlay)
            Container(
              color: widget.theme.colorScheme.surface.withAlpha(
                230,
              ), // Semi-transparent background
              child: Center(child: _buildTaskOverlay()),
            ),
        ],
      ),
    );
  }
}
