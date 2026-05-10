part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadTasksEvent extends DashboardEvent {
  final String userId;

  const DashboardLoadTasksEvent({required this.userId});
  @override
  List<Object> get props => [userId];
}

class DashboardAddTaskEvent extends DashboardEvent {
  final String userId;
  final Task task;

  const DashboardAddTaskEvent({required this.task, required this.userId});
  @override
  List<Object> get props => [task, userId];
}

class DashboardDeleteTaskEvent extends DashboardEvent {
  final String userId;
  final String taskId;
  const DashboardDeleteTaskEvent({required this.taskId, required this.userId});
  @override
  List<Object> get props => [taskId, userId];
}

class DashboardUpdateTaskEvent extends DashboardEvent {
  final String userId;
  final Task task;
  const DashboardUpdateTaskEvent({required this.task, required this.userId});
  @override
  List<Object> get props => [task, userId];
}

class DashboardHighlightTaskEvent extends DashboardEvent {
  final String highlightedTaskId;

  const DashboardHighlightTaskEvent({required this.highlightedTaskId});
  @override
  List<Object> get props => [highlightedTaskId];
}

class DashboardUpdateFiltersEvent extends DashboardEvent {
  final FilterModel filters;

  const DashboardUpdateFiltersEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class DashboardUpdateTaskListFiltersEvent extends DashboardEvent {
  final FilterModel filters;

  const DashboardUpdateTaskListFiltersEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class DashboardTabChangedEvent extends DashboardEvent {
  final int tabIndex;

  const DashboardTabChangedEvent({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

class DashboardUpdateTaskStatusEvent extends DashboardEvent {
  final String userId;
  final String taskId;
  final bool isCompleted;

  const DashboardUpdateTaskStatusEvent({
    required this.taskId,
    required this.isCompleted,
    required this.userId,
  });

  @override
  List<Object> get props => [taskId, isCompleted, userId];
}

class DashboardFetchQuoteEvent extends DashboardEvent {}

class DashboardUpdateTaskListStatusFilterEvent extends DashboardEvent {
  final TaskListStatusFilter statusFilter;

  const DashboardUpdateTaskListStatusFilterEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}