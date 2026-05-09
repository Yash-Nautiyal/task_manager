import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';

import '../../../../core/constants/app_icons.dart';

class CalendarOverlayTaskItem extends StatelessWidget {
  final Task task;
  final ThemeData theme;
  final Function(int, String?) onTaskSelected;

  const CalendarOverlayTaskItem({
    super.key,
    required this.task,
    required this.theme,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (task.status) {
      case TaskStatus.todo:
        statusColor = Colors.blue;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'To Do';
        break;

      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case TaskStatus.overdue:
        statusColor = AppPallete.errorMain;
        statusIcon = Icons.error;
        statusText = 'Overdue';
        break;
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              task.status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () => onTaskSelected.call(1, task.id),
          icon: SvgPicture.asset(
            AppIcons.redirectIcon,
            width: 20,
            color: AppPallete.infoMain,
          ),
        ),
      ],
    );
  }
}
