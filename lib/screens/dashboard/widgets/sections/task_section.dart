import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/models/task_model.dart';

import '../../bloc/dashboard_bloc.dart';
import '../db_task_list.dart';

class TaskSection extends StatelessWidget {
  final String userId;
  final TabController tabController;
  final ScrollController scrollController;
  final ThemeData theme;
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
              filteredTasks: sortedTasks,
              showAllTasks: showAllTasks,
              toggleTaskList: toggleTaskList,
              expandController: expandController,
              showAddTaskDialog:
                  (task) => showAddTaskDialog(task: task, isEdit: true),
              onDeleteTask: (taskId) async {
                context.read<DashboardBloc>().add(
                  DashboardDeleteTaskEvent(taskId: taskId, userId: userId),
                );
              },
              onCompleteTask: (taskId, value) {
                context.read<DashboardBloc>().add(
                  DashboardUpdateTaskStatusEvent(
                    taskId: taskId,
                    userId: userId,
                    isCompleted: value,
                  ),
                );
              },
              onCompleteSubtask: (taskId, subTaskId, isCompleted) {
                context.read<DashboardBloc>().add(
                  DashboardUpdateSubTaskStatusEvent(
                    taskId: taskId,
                    subtaskId: subTaskId,
                    userId: userId,
                    isCompleted: isCompleted,
                  ),
                );
              },
              onDeleteSubtask: (subtaskId, taskId) {
                context.read<DashboardBloc>().add(
                  DashboardDeleteSubTaskEvent(
                    taskId: taskId,
                    subtaskId: subtaskId,
                    userId: userId,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
