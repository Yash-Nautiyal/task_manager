// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/dashboard/widgets/dialogs/delete_dialog.dart';
import 'package:task_app/screens/tasks/widgets/card/task_card_footer.dart';
import 'package:task_app/screens/tasks/widgets/card/task_card_header.dart';
import 'package:task_app/widgets/popup/responsive_popup.dart';

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
  late final AnimationController _highlightController;
  late final Animation<double> _highlightAnimation;

  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

  static const List<Color> _palette = [
    AppPallete.infoMain,
    AppPallete.warningMain,
    AppPallete.primaryMain,
    AppPallete.secondaryMain,
  ];

  @override
  void initState() {
    super.initState();

    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
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
    final confirmed = await showDeleteDialog(context, 'task');
    if (confirmed) widget.onDelete();
  }

  Color _accentColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.completed => AppPallete.successMain,
      TaskStatus.overdue => AppPallete.errorMain,
      _ => _palette[widget.task.id.hashCode.abs() % _palette.length],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final status =
        widget.task.status == TaskStatus.completed
            ? TaskStatus.completed
            : widget.task.isOverdue
            ? TaskStatus.overdue
            : TaskStatus.todo;

    final accent = _accentColor(status);

    final cardSurface =
        isDark
            ? Color.alphaBlend(
              Colors.white.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            )
            : Colors.white;

    return AnimatedBuilder(
      key: ValueKey(widget.task.id),
      animation: _highlightAnimation,
      builder: (context, _) {
        final glow = _highlightAnimation.value;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.08 + 0.22 * glow)
                      : Colors.black.withOpacity(0.07 + 0.10 * glow),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.40)
                        : Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              if (glow > 0)
                BoxShadow(
                  color: accent.withOpacity(0.50 * glow),
                  blurRadius: 20 * glow,
                  spreadRadius: 1 * glow,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [accent, accent.withOpacity(0.55)],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskCardHeader(
                          status: status,
                          title: widget.task.title,
                          theme: theme,
                          popupAnchorKey: _popupAnchorKey,
                          layerLink: _layerLink,
                          popupController: _popupController,
                          onEdit: widget.onEdit,
                          onCompleteTask:
                              (value) => widget.onCompleteTask(value),
                          onDelete: _deleteTask,
                        ),

                        if (widget.task.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
                            child: Text(
                              widget.task.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.55,
                                ),
                                height: 1.45,
                              ),
                            ),
                          ),

                        TaskCardFooter(
                          status: status,
                          theme: theme,
                          dueDate: widget.task.dueDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
