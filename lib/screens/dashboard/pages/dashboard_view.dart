import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/widgets/common/dialog/snackbar_dialog.dart';
import 'package:task_app/widgets/common/loader/custom_loader.dart';
import '../../../core/helpers/task_helpers.dart'
    show applyFilters, getSortedTasks;
import '../../../models/task_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/db_tab_bar.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/sections/chart_section.dart';
import '../widgets/sections/task_section.dart';
import '../widgets/sections/header_section.dart';

class DashboardView extends StatefulWidget {
  final Function(int, String?) onPageChanged;
  final String userId;
  final User? user;
  const DashboardView({
    super.key,
    required this.onPageChanged,
    required this.user,
    required this.userId,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late TabController _tabController;
  late AnimationController _expandController;
  late ConfettiController _confettiController;
  bool allTasksCompleted = false;
  final tabs = ['Today', 'Tomorrow', 'This Week', 'This Month', 'Completed'];
  bool _showAllTasks = false;
  final _scrollController = ScrollController();

  void _showAddTaskDialog({Task? task, bool isEdit = false}) {
    showAddTaskDialog(
      context: context,
      userId: widget.userId,
      task: task,
      isEdit: isEdit,
      onTaskCreated: (createdTask) {
        if (isEdit) {
          context.read<DashboardBloc>().add(
            DashboardUpdateTaskEvent(userId: widget.userId, task: createdTask),
          );
          return;
        }
        context.read<DashboardBloc>().add(
          DashboardAddTaskEvent(userId: widget.userId, task: createdTask),
        );
      },
    );
  }

  void showAddTaskDialog({
    required BuildContext context,
    required String userId,
    Task? task,
    bool isEdit = false,
    required Function(Task) onTaskCreated,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AddTaskDialog(
            isEdit: isEdit,
            task: task,
            theme: Theme.of(context),
            onTaskCreated: (task) {
              onTaskCreated(task);
            },
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(
      DashboardLoadTasksEvent(userId: widget.userId),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final blocState = context.read<DashboardBloc>().state;
    int initialTabIndex = 0;
    if (blocState.status == DashboardStatus.loaded) {
      initialTabIndex = blocState.currentTaskIndex;
    }
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: initialTabIndex,
    );

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );
  }

  void _toggleTaskList() {
    if (_showAllTasks) {
      _expandController.reverse().then((_) {
        setState(() {
          _showAllTasks = false;
        });
      });
    } else {
      setState(() {
        _showAllTasks = true;
        _expandController.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandController.dispose();
    _tabController.dispose();
    _confettiController.dispose();

    super.dispose();
  }

  void _triggerConfetti() => _confettiController.play();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen:
          (previous, current) =>
              current.uiAction != null && previous.uiAction != current.uiAction,
      listener: (context, state) {
        final action = state.uiAction!;
        if (action.type == UIActionType.error) {
          showAnimatedSnackbar(
            context,
            action.message ?? 'Error',
            SnackbarType.error,
          );
        } else if (action.type == UIActionType.success) {
          showAnimatedSnackbar(
            context,
            action.message ?? 'Success',
            SnackbarType.success,
          );
        } else if (action.type == UIActionType.confetti) {
          _triggerConfetti();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              BlocBuilder<DashboardBloc, DashboardState>(
                buildWhen:
                    (previous, current) =>
                        previous.status != current.status ||
                        previous.alltasks != current.alltasks ||
                        previous.currentTaskIndex != current.currentTaskIndex,
                builder: (context, state) {
                  if (state.status == DashboardStatus.loading ||
                      state.status == DashboardStatus.initial) {
                    return const Center(child: CustomLoader());
                  }
                  if (state.status == DashboardStatus.error) {
                    return Center(
                      child: Text(state.globalError ?? 'An error occurred.'),
                    );
                  }
                  if (state.status == DashboardStatus.loaded) {
                    Task? priorityTask =
                        state.filteredTasks.isNotEmpty
                            ? state.filteredTasks.first
                            : null;

                    List<Task> sortedTasks = getSortedTasks(
                      state.filteredTasks,
                    );
                    final tabCounts = List<int>.generate(
                      tabs.length,
                      (index) =>
                          applyFilters(
                            state.alltasks,
                            state.currentFilters,
                            tabIndex: index,
                          ).length,
                    );

                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Header Section (Stationary)
                        HeaderSection(
                          quote: state.quote,
                          theme: theme,
                          controller: _controller,
                          user: widget.user,
                          allTasks: state.alltasks,
                          currentFilters: state.currentFilters,
                          showAddTaskDialog: _showAddTaskDialog,
                        ),
                        // Persistent Tab Bar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            DbTabBar(
                              theme: theme,
                              tabController: _tabController,
                              tabs: tabs,
                              tabCounts: tabCounts,
                              onTabSelected: (index) {
                                context.read<DashboardBloc>().add(
                                  DashboardTabChangedEvent(tabIndex: index),
                                );
                                if (_showAllTasks) {
                                  _expandController.reverse().then((_) {
                                    setState(() {
                                      _showAllTasks = false;
                                    });
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        TaskSection(
                          theme: theme,
                          userId: widget.userId,
                          tabController: _tabController,
                          scrollController: _scrollController,
                          prioritytask: priorityTask,
                          sortedTasks: sortedTasks,
                          showAllTasks: _showAllTasks,
                          toggleTaskList: _toggleTaskList,
                          showAddTaskDialog: _showAddTaskDialog,
                          expandController: _expandController,
                          completeTask: (taskId, value) {
                            context.read<DashboardBloc>().add(
                              DashboardUpdateTaskStatusEvent(
                                userId: widget.userId,
                                taskId: taskId,
                                isCompleted: value,
                              ),
                            );
                          },
                        ),
                        // Charts Section (Stationary)
                        ChartSection(
                          theme: theme,
                          tasks: state.alltasks,
                          onPageChanged: widget.onPageChanged,
                        ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality:
                      BlastDirectionality.explosive, // random direction
                  shouldLoop: false,
                  emissionFrequency: 0.03,
                  numberOfParticles: 50,
                  maxBlastForce: 20,
                  minBlastForce: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child);

  final Widget _child;

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate._child != _child;
  }
}
