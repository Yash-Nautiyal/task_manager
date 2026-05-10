import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/dashboard/widgets/dialogs/delete_dialog.dart';
import 'package:task_app/screens/tasks/widgets/card/task_card_footer.dart';
import 'package:task_app/screens/tasks/widgets/card/task_card_header.dart';
import 'package:task_app/widgets/common/popup/responsive_popup.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function onCompleteTask;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isHighlighted;
  final bool grid;
  final int colorIndex;
  const TaskCard({
    super.key,
    required this.task,
    required this.onCompleteTask,
    required this.onEdit,
    required this.onDelete,
    this.grid = false,
    this.isHighlighted = false,
    required this.colorIndex,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

  @override
  void initState() {
    super.initState();

    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
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

  List<Color> colorOptions = [
    AppPallete.infoMain,
    AppPallete.warningMain,
    AppPallete.primaryMain,
    AppPallete.secondaryMain,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status =
        widget.task.status == TaskStatus.completed
            ? TaskStatus.completed
            : widget.task.isOverdue
            ? TaskStatus.overdue
            : TaskStatus.todo;

    final Color taskColor =
        (status == TaskStatus.completed)
            ? AppPallete.successMain
            : (status == TaskStatus.overdue)
            ? AppPallete.errorMain
            : colorOptions[widget.colorIndex % colorOptions.length];

    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    return AnimatedBuilder(
      key: ValueKey(widget.task.id),
      animation: _highlightController,
      builder: (context, child) {
        final value = _highlightAnimation.value;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

          decoration: BoxDecoration(
            color:
                value > 0
                    ? taskColor.withValues(alpha: (isDark ? 0.55 : 0.1) * value)
                    : taskColor.withValues(alpha: (isDark ? 0.55 : 0.15)),
            border: Border.all(
              color: taskColor.withValues(alpha: 0.02 + 0.4 * value),
              width: 1.5,
            ),
            boxShadow:
                value > 0
                    ? [
                      BoxShadow(
                        color: theme.primaryColor.withValues(
                          alpha: 0.4 * value,
                        ),
                        blurRadius: 12 * value,
                        spreadRadius: 2 * value,
                      ),
                    ]
                    : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //CheckBox
              TaskCardHeader(
                status: status,
                title: widget.task.title,
                theme: theme,
                popupAnchorKey: _popupAnchorKey,
                layerLink: _layerLink,
                popupController: _popupController,
                onEdit: widget.onEdit,
                onCompleteTask: (value) => widget.onCompleteTask(value),
                onDelete: _deleteTask,
              ),
              //Description
              if (widget.task.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.task.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],

              TaskCardFooter(
                status: status,
                theme: theme,
                dueDate: widget.task.dueDate,
              ),
            ],
          ),
        );
      },
    );
  }
}
