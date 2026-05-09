part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

sealed class DashboardListenState extends DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoadingState extends DashboardState {}

final class DashboardDataLoadedState extends DashboardState {
  final String quote;
  final List<Task> alltasks;
  final List<Task> filteredTasks;
  final FilterModel currentFilters;
  final String? highlightedTaskId;
  final int currentTaskIndex;

  const DashboardDataLoadedState({
    required this.alltasks,
    required this.filteredTasks,
    required this.currentFilters,
    required this.currentTaskIndex,
    required this.quote,
    this.highlightedTaskId,
  });

  @override
  List<Object?> get props => [
    alltasks,
    filteredTasks,
    currentFilters,
    quote,
    highlightedTaskId,
    currentTaskIndex,
  ];

  DashboardDataLoadedState copyWith({
    List<Task>? alltasks,
    List<Task>? filteredTasks,
    FilterModel? currentFilters,
    int? currentTaskIndex,
    String? highlightedTaskId,
    String? quote,
  }) {
    return DashboardDataLoadedState(
      quote: quote ?? this.quote,
      alltasks: alltasks ?? this.alltasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      currentFilters: currentFilters ?? this.currentFilters,
      currentTaskIndex: currentTaskIndex ?? this.currentTaskIndex,
      highlightedTaskId: highlightedTaskId ?? this.highlightedTaskId,
    );
  }
}

class DashboardDataErrorState extends DashboardListenState {
  final String error;

  DashboardDataErrorState({required this.error});
  @override
  List<Object> get props => [error];
}

class DashboardDataSucssfulState extends DashboardListenState {
  final String successMessage;
  DashboardDataSucssfulState({required this.successMessage});
  @override
  List<Object> get props => [successMessage];
}

class DashboardTaskCompletedState extends DashboardListenState {}
