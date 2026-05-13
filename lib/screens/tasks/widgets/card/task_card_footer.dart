// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_app/core/constants/app_icons.dart';
import 'package:task_app/core/helpers/date_time_helper.dart';
import 'package:task_app/core/helpers/task_helpers.dart';
import 'package:task_app/models/task_model.dart';

class TaskCardFooter extends StatelessWidget {
  final TaskStatus status;
  final ThemeData theme;
  final DateTime dueDate;

  const TaskCardFooter({
    super.key,
    required this.status,
    required this.theme,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 16, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _StatusBadge(status: status, theme: theme, isDark: isDark),
          _DueDateBadge(dueDate: dueDate, theme: theme, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final ThemeData theme;
  final bool isDark;

  const _StatusBadge({
    required this.status,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.40 : 0.22),
          width: 1,
        ),
      ),
      child: Text(
        status.text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isDark ? color.withOpacity(0.90) : color,
        ),
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final ThemeData theme;
  final bool isDark;

  const _DueDateBadge({
    required this.dueDate,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        isDark ? Colors.white.withOpacity(0.50) : theme.colorScheme.outline;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.calendarIcon,
            width: 20,
            colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 5),
          Text(
            'Due: ${formatDateTime(dueDate)}',
            style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
