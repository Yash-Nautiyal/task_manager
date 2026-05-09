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

class DashboardTabChangedEvent extends DashboardEvent {
  final int tabIndex;

  const DashboardTabChangedEvent({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

class DashboardDeleteSubTaskEvent extends DashboardEvent {
  final String userId;
  final String taskId;
  final String subtaskId;

  const DashboardDeleteSubTaskEvent({
    required this.taskId,
    required this.subtaskId,
    required this.userId,
  });
  @override
  List<Object> get props => [taskId, subtaskId, userId];
}

class DashboardUpdateSubTaskStatusEvent extends DashboardEvent {
  final String userId;
  final String taskId;
  final String subtaskId;
  final bool isCompleted;

  const DashboardUpdateSubTaskStatusEvent({
    required this.taskId,
    required this.subtaskId,
    required this.userId,
    required this.isCompleted,
  });
  @override
  List<Object> get props => [taskId, subtaskId, userId, isCompleted];
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

class TaskUpdatedFromDb extends DashboardEvent {
  final Task task;
  const TaskUpdatedFromDb(this.task);
}
