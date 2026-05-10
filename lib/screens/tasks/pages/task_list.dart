import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../core/helpers/task_helpers.dart';
import '../../../models/task_model.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/widgets/db_add_button.dart';
import '../../dashboard/widgets/db_filters.dart';
import '../../dashboard/widgets/dialogs/add_task_dialog.dart';
import '../../dashboard/widgets/empty_tasks.dart';
import '../widgets/status_pills.dart';
import '../widgets/task_card.dart';

class TaskList extends StatefulWidget {
  final String userId;
  final String? highlightTaskId;

  const TaskList({super.key, this.highlightTaskId, required this.userId});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final ScrollController _scrollController = ScrollController();
  late final ListObserverController _observerController;
  late final ConfettiController _confettiController;

  bool grid = false;
  String? _highlightedTaskId;
  bool _hasHighlighted = false;

  @override
  void initState() {
    super.initState();
    _observerController = ListObserverController(controller: _scrollController);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    _highlightedTaskId = widget.highlightTaskId;
  }

  @override
  void didUpdateWidget(covariant TaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightTaskId != oldWidget.highlightTaskId &&
        widget.highlightTaskId != null) {
      setState(() {
        _highlightedTaskId = widget.highlightTaskId;
        _hasHighlighted = false;
      });
    }
  }

  void _triggerConfetti() => _confettiController.play();

  void _highlightAndScrollToTask(List<Task> currentTasks) {
    if (_highlightedTaskId == null || _hasHighlighted) return;

    final taskIndex = currentTasks.indexWhere(
      (task) => task.id == _highlightedTaskId,
    );
    if (taskIndex != -1) {
      _hasHighlighted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _observerController
            .animateTo(
              index: taskIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              offset: (targetOffset) => 100,
            )
            .then((_) {
              if (!mounted) return;
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) setState(() => _highlightedTaskId = null);
              });
            });
      });
    }
  }

  void _showAddTaskDialog({Task? task, bool isEdit = false}) {
    final dashboardBloc = context.read<DashboardBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AddTaskDialog(
            isEdit: isEdit,
            task: task,
            theme: Theme.of(context),
            onTaskCreated: (createdTask) {
              if (isEdit) {
                dashboardBloc.add(
                  DashboardUpdateTaskEvent(
                    userId: widget.userId,
                    task: createdTask,
                  ),
                );
              } else {
                dashboardBloc.add(
                  DashboardAddTaskEvent(
                    userId: widget.userId,
                    task: createdTask,
                  ),
                );
              }
            },
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen:
              (previous, current) =>
                  current.uiAction != null &&
                  previous.uiAction != current.uiAction,
          listener: (context, state) {
            final action = state.uiAction!;
            if (action.type == UIActionType.confetti) {
              _triggerConfetti();
            }
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen:
                (previous, current) =>
                    previous.status != current.status ||
                    previous.alltasks != current.alltasks ||
                    previous.taskListFilters != current.taskListFilters ||
                    previous.taskListStatusFilter !=
                        current.taskListStatusFilter,
            builder: (context, state) {
              if (state.status == DashboardStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == DashboardStatus.loaded) {
                final sortedTasks = getSortedTasks(state.alltasks);
                final baseFilteredTasks = applyFilters(
                  sortedTasks,
                  state.taskListFilters,
                  applyTabFilter: false,
                );

                final allCount = baseFilteredTasks.length;
                final todoCount =
                    baseFilteredTasks
                        .where(
                          (t) =>
                              t.status != TaskStatus.completed && !t.isOverdue,
                        )
                        .length;
                final overdueCount =
                    baseFilteredTasks.where((t) => t.isOverdue).length;
                final completedCount =
                    baseFilteredTasks
                        .where((t) => t.status == TaskStatus.completed)
                        .length;

                final finalTasksToDisplay = applyStatusFilter(
                  baseFilteredTasks,
                  state.taskListStatusFilter,
                );

                _highlightAndScrollToTask(finalTasksToDisplay);

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          20,
                        ).copyWith(top: MediaQuery.paddingOf(context).top + 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Tasks',
                              style: theme.textTheme.displaySmall,
                            ),
                            DbFilters(
                              theme: theme,
                              allTasks: state.alltasks,
                              onFiltersChanged: (newFilters) {
                                context.read<DashboardBloc>().add(
                                  DashboardUpdateTaskListFiltersEvent(
                                    filters: newFilters,
                                  ),
                                );
                              },
                            ),
                            DbAddButton(
                              theme: theme,
                              onPressed: () => _showAddTaskDialog(),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  StatusPill(
                                    label: 'All Tasks',
                                    count: allCount,
                                    isSelected:
                                        state.taskListStatusFilter ==
                                        TaskListStatusFilter.all,
                                    theme: theme,
                                    onTap:
                                        () => context.read<DashboardBloc>().add(
                                          const DashboardUpdateTaskListStatusFilterEvent(
                                            TaskListStatusFilter.all,
                                          ),
                                        ),
                                  ),
                                  StatusPill(
                                    label: 'Ongoing',
                                    count: todoCount,
                                    isSelected:
                                        state.taskListStatusFilter ==
                                        TaskListStatusFilter.todo,
                                    theme: theme,
                                    onTap:
                                        () => context.read<DashboardBloc>().add(
                                          const DashboardUpdateTaskListStatusFilterEvent(
                                            TaskListStatusFilter.todo,
                                          ),
                                        ),
                                  ),
                                  StatusPill(
                                    label: 'Overdue',
                                    count: overdueCount,
                                    isSelected:
                                        state.taskListStatusFilter ==
                                        TaskListStatusFilter.overdue,
                                    theme: theme,
                                    onTap:
                                        () => context.read<DashboardBloc>().add(
                                          const DashboardUpdateTaskListStatusFilterEvent(
                                            TaskListStatusFilter.overdue,
                                          ),
                                        ),
                                  ),
                                  StatusPill(
                                    label: 'Completed',
                                    count: completedCount,
                                    isSelected:
                                        state.taskListStatusFilter ==
                                        TaskListStatusFilter.completed,
                                    theme: theme,
                                    onTap:
                                        () => context.read<DashboardBloc>().add(
                                          const DashboardUpdateTaskListStatusFilterEvent(
                                            TaskListStatusFilter.completed,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                      ).copyWith(bottom: 20),
                      sliver:
                          finalTasksToDisplay.isEmpty
                              ? const SliverToBoxAdapter(child: EmptyTasks())
                              : ListViewObserver(
                                controller: _observerController,
                                child: SliverList.builder(
                                  itemCount: finalTasksToDisplay.length,
                                  itemBuilder: (context, index) {
                                    final task = finalTasksToDisplay[index];
                                    return TaskCard(
                                      key: ValueKey('task_${task.id}'),
                                      grid: grid,
                                      task: task,
                                      colorIndex: index,
                                      isHighlighted:
                                          task.id == _highlightedTaskId,
                                      onCompleteTask: (value) {
                                        context.read<DashboardBloc>().add(
                                          DashboardUpdateTaskStatusEvent(
                                            taskId: task.id,
                                            userId: widget.userId,
                                            isCompleted: value,
                                          ),
                                        );
                                      },
                                      onEdit:
                                          () => _showAddTaskDialog(
                                            task: task,
                                            isEdit: true,
                                          ),
                                      onDelete: () {
                                        context.read<DashboardBloc>().add(
                                          DashboardDeleteTaskEvent(
                                            taskId: task.id,
                                            userId: widget.userId,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.03,
            numberOfParticles: 50,
          ),
        ),
      ],
    );
  }
}
