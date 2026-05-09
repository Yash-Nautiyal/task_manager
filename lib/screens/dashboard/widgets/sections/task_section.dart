import 'package:flutter/material.dart';
import 'package:task_app/models/task_model.dart';

import '../db_task_list.dart';

class TaskSection extends StatelessWidget {
  final String userId;
  final TabController tabController;
  final ScrollController scrollController;
  final ThemeData theme;
  final Task? prioritytask;
  final List<Task> sortedTasks;
  final bool showAllTasks;
  final Function toggleTaskList;
  final AnimationController expandController;
  final Function showAddTaskDialog;
  const TaskSection({
    super.key,
    required this.userId,
    required this.tabController,
    required this.scrollController,
    required this.theme,
    required this.prioritytask,
    required this.sortedTasks,
    required this.showAllTasks,
    required this.toggleTaskList,
    required this.showAddTaskDialog,
    required this.expandController,
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
              onDeleteTask: (taskId) async {},
              onCompleteTask: (taskId, value) {},
            ),
          );
        },
      ),
    );
  }
}
