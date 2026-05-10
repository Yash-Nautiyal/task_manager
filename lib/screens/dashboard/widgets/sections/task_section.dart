import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';

import '../db_task_list.dart';

class TaskSection extends StatelessWidget {
  final String userId;
  final ThemeData theme;
  final TabController tabController;
  final ScrollController scrollController;
  final Task? prioritytask;
  final List<Task> sortedTasks;
  final bool showAllTasks;
  final Function toggleTaskList;
  final Function showAddTaskDialog;
  final AnimationController expandController;
  final Function(String taskId, bool value) completeTask;
  final Function(String taskId) onDeleteTask;
  const TaskSection({
    super.key,
    required this.theme,
    required this.userId,
    required this.tabController,
    required this.scrollController,
    required this.prioritytask,
    required this.sortedTasks,
    required this.showAllTasks,
    required this.toggleTaskList,
    required this.showAddTaskDialog,
    required this.expandController,
    required this.completeTask,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DbTaskList(
              scrollController: scrollController,
              theme: theme,
              prioritytask: prioritytask,
              filteredTasks: sortedTasks,
              showAllTasks: showAllTasks,
              toggleTaskList: toggleTaskList,
              expandController: expandController,
              showAddTaskDialog:
                  (task) => showAddTaskDialog(task: task, isEdit: true),
              onDeleteTask: (taskId) => onDeleteTask(taskId),
              onCompleteTask: (taskId, value) => completeTask(taskId, value),
            ),
          );
        },
      ),
    );
  }
}
