import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_app/core/helpers/date_time_helper.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';

import '../../../core/constants/app_icons.dart' show AppIcons;
import '../../../core/helpers/task_helpers.dart';
import 'dialogs/delete_dialog.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function onCompleteTask;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isHighlighted;
  final bool grid;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCompleteTask,
    required this.onEdit,
    required this.onDelete,
    this.grid = false,
    this.isHighlighted = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();

    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    _highlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _highlightController.reverse();
      }
    });

    if (widget.isHighlighted) {
      _highlightController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  void _deleteTask() async {
    bool confirm = await showDeleteDialog(context, 'task');
    if (confirm) {
      widget.onDelete.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status =
        widget.task.status == TaskStatus.completed
            ? TaskStatus.completed
            : widget.task.isOverdue
            ? TaskStatus.overdue
            : TaskStatus.todo;

    return AnimatedBuilder(
      key: ValueKey(widget.task.id),
      animation: _highlightController,
      builder: (context, child) {
        final value = _highlightAnimation.value;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color:
                widget.isHighlighted
                    ? theme.primaryColor.withValues(alpha: 0.08 * value)
                    : null,
            border: Border.all(
              color:
                  status == TaskStatus.completed
                      ? AppPallete.successMain
                      : theme.dividerColor.withAlpha(100),
              width: 1.5,
            ),
            boxShadow:
                widget.isHighlighted
                    ? [
                      BoxShadow(
                        color: theme.primaryColor.withValues(
                          alpha: 0.3 * value,
                        ),
                        blurRadius: 8 * value,
                        spreadRadius: 2 * value,
                      ),
                    ]
                    : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status == TaskStatus.overdue ||
                  status == TaskStatus.completed)
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.text,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: status.color,
                      ),
                    ),
                  ),
                ),

              //CheckBox
              Padding(
                padding: EdgeInsets.only(
                  right: 16.0,
                  top:
                      status != TaskStatus.completed
                          ? status != TaskStatus.overdue
                              ? 10
                              : 0
                          : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: status == TaskStatus.completed,
                      activeColor: AppPallete.successMain,
                      checkColor: AppPallete.white,
                      onChanged: (value) {
                        widget.onCompleteTask.call(value!);
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.task.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration:
                              status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              status == TaskStatus.completed
                                  ? AppPallete.successMain
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Description
              if (widget.task.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ).copyWith(bottom: 16),
                  child: Text(
                    widget.task.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (status == TaskStatus.completed)
                          Container(
                            decoration: BoxDecoration(
                              color: AppPallete.successLight.withValues(
                                alpha:
                                    theme.brightness == Brightness.dark
                                        ? 0.2
                                        : .3,
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.checkRoundedIcon,
                                  colorFilter: ColorFilter.mode(
                                    AppPallete.successMain,
                                    BlendMode.srcIn,
                                  ),
                                  width: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Completed: ${widget.task.status == TaskStatus.completed
                                      ? widget.task.completedAt != null
                                          ? formatDateTime(widget.task.completedAt!)
                                          : "--"
                                      : 'Not completed'}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppPallete.successMain,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 7,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.calendarIcon,
                                color: theme.dividerColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Due: ${formatDateTime(widget.task.dueDate)}',
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
                    const Spacer(),
                    if (status != TaskStatus.completed)
                      IconButton(
                        icon: SvgPicture.asset(
                          AppIcons.penBoldIcon,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primaryContainer,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                        ),
                        onPressed: () => widget.onEdit.call(),
                      ),
                    if (status != TaskStatus.completed)
                      IconButton(
                        icon: SvgPicture.asset(
                          AppIcons.trashBoldIcon,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.error,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                        ),
                        onPressed: _deleteTask,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
