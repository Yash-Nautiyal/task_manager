import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';

class CalendarIndicator extends StatelessWidget {
  final DateTime day;
  final List<Task> tasks;
  final ThemeData theme;
  final Animation<double> animation;

  const CalendarIndicator({
    super.key,
    required this.day,
    required this.tasks,
    required this.theme,
    required this.animation,
  });

  Map<TaskStatus, int> _getTaskCountsByStatus() {
    final counts = <TaskStatus, int>{
      TaskStatus.todo: 0,
      TaskStatus.completed: 0,
      TaskStatus.overdue: 0,
    };

    for (final task in tasks) {
      if (task.status == TaskStatus.completed) {
        counts[TaskStatus.completed] = counts[TaskStatus.completed]! + 1;
      } else if (task.isOverdue) {
        counts[TaskStatus.overdue] = counts[TaskStatus.overdue]! + 1;
      } else {
        counts[TaskStatus.todo] = counts[TaskStatus.todo]! + 1;
      }
    }

    return counts;
  }

  Widget _buildModernIndicator(Color color, int count, TaskStatus status) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        count.toString(),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall!.copyWith(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final counts = _getTaskCountsByStatus();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 25,
              children: [
                if (counts[TaskStatus.todo]! > 0)
                  _buildModernIndicator(
                    Colors.blue,
                    counts[TaskStatus.todo]!,
                    TaskStatus.todo,
                  ),

                if (counts[TaskStatus.completed]! > 0)
                  _buildModernIndicator(
                    Colors.green,
                    counts[TaskStatus.completed]!,
                    TaskStatus.completed,
                  ),
                if (counts[TaskStatus.overdue]! > 0)
                  _buildModernIndicator(
                    AppPallete.errorMain,
                    counts[TaskStatus.overdue]!,
                    TaskStatus.overdue,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
