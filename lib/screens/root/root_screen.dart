import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_app/screens/auth/bloc/auth_bloc.dart';

import '../../widgets/appBar/home_appbar.dart';
import '../../widgets/dialog/snackbar_dialog.dart';
import '../dashboard/bloc/dashboard_bloc.dart';
import '../dashboard/pages/dashboard_view.dart';
import '../tasks/pages/task_list.dart';

class RootScreen extends StatefulWidget {
  final User user;
  final int initialIndex;
  final String? initialHighlightTaskId;

  const RootScreen({
    super.key,
    required this.user,
    this.initialIndex = 0,
    this.initialHighlightTaskId,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _currentIndex;
  String? _highlightedTaskId;
  late DashboardBloc _dashboardBloc;
  late User user;

  @override
  void initState() {
    super.initState();
    user =
        context.read<AuthBloc>().state is Authenticated
            ? (context.read<AuthBloc>().state as Authenticated).user
            : widget.user;
    print(
      'RootScreen initialized with user: ${user.uid}, displayName: ${user.displayName}',
    );
    _currentIndex = widget.initialIndex;
    _highlightedTaskId = widget.initialHighlightTaskId;

    _dashboardBloc =
        DashboardBloc()..add(DashboardLoadTasksEvent(userId: widget.user.uid));
  }

  void _onPageChanged(int index, String? taskId) {
    setState(() {
      _currentIndex = index;
      if (taskId != null) {
        _highlightedTaskId = taskId;
      } else if (index != 1) {
        _highlightedTaskId = null;
      }
    });
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  Future<void> _refreshTasks() async {
    _dashboardBloc.add(DashboardLoadTasksEvent(userId: user.uid));
    _dashboardBloc.add(DashboardFetchQuoteEvent());

    try {
      await _dashboardBloc.stream
          .firstWhere(
            (state) =>
                state.status == DashboardStatus.loaded ||
                state.status == DashboardStatus.error,
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _dashboardBloc,
      child: BlocListener<DashboardBloc, DashboardState>(
        listenWhen:
            (previous, current) =>
                current.uiAction != null &&
                previous.uiAction != current.uiAction,
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
          }
        },
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(overscroll: false),
          child: RefreshIndicator(
            onRefresh: _refreshTasks,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              extendBodyBehindAppBar: true,
              appBar: HomeAppBar(
                theme: theme,
                dashboardPage: true,
                showBackButton: false,
                currentIndex: _currentIndex,
                onPageChanged: _onPageChanged,
              ),
              body: SafeArea(
                top: false,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    DashboardView(
                      onPageChanged: _onPageChanged,
                      userId: user.uid,
                      user: user,
                    ),

                    TaskList(
                      highlightTaskId: _highlightedTaskId,
                      userId: user.uid,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
