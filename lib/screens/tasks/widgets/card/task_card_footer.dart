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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  status.color.withValues(alpha: 0.9),
                  status.color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),

          Container(
            height: 30,
            decoration: BoxDecoration(
              color: theme.dividerColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppIcons.calendarIcon,
                  colorFilter: ColorFilter.mode(
                    theme.dividerColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Due: ${formatDateTime(dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
