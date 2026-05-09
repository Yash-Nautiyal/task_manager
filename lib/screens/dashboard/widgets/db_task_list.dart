import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';

import 'empty_tasks.dart';
import 'task_card.dart';

class DbTaskList extends StatelessWidget {
  final List<Task> filteredTasks;
  final Task? prioritytask;
  final bool showAllTasks;
  final Function toggleTaskList;
  final Function onCompleteTask;
  final Function showAddTaskDialog;
  final Function onDeleteTask;
  final AnimationController expandController;
  final ScrollController scrollController;
  final ThemeData theme;
  const DbTaskList({
    super.key,
    this.prioritytask,
    required this.scrollController,
    required this.theme,
    required this.filteredTasks,
    required this.showAllTasks,
    required this.onDeleteTask,
    required this.onCompleteTask,
    required this.toggleTaskList,
    required this.showAddTaskDialog,
    required this.expandController,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredTasks.isEmpty) {
      return const EmptyTasks();
    }
    final priorityTask = prioritytask;
    final remainingTasks =
        filteredTasks.where((item) => item.id != priorityTask?.id).toList();
    return Column(
      children: [
        if (priorityTask != null)
          TaskCard(
            task: priorityTask,
            onCompleteTask: (value) => onCompleteTask(priorityTask.id, value),
            onEdit: () => showAddTaskDialog(priorityTask),
            onDelete: () => onDeleteTask(priorityTask.id),
          ),
        AnimatedSlide(
          offset: Offset(0, showAllTasks ? 0 : 0.1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: showAllTasks ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: SizeTransition(
              sizeFactor: expandController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: remainingTasks.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final task = remainingTasks[index];
                  return TaskCard(
                    onCompleteTask: (value) => onCompleteTask(task.id, value),
                    task: task,
                    onEdit: () => showAddTaskDialog(task),
                    onDelete: () => onDeleteTask(task.id),
                  );
                },
              ),
            ),
          ),
        ),
        remainingTasks.isNotEmpty
            ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.dividerColor.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => toggleTaskList(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAllTasks
                            ? 'Collapse'
                            : 'View All Tasks (${remainingTasks.length})',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: showAllTasks ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            : const SizedBox.shrink(),
        const SizedBox(height: 16),
      ],
    );
  }
}
