part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

enum UIActionType { success, error, confetti }

class DashboardInitial extends DashboardState {}

class DashboardUIAction extends Equatable {
  final UIActionType type;
  final String? message;
  final int _timestamp;

  DashboardUIAction({required this.type, this.message})
    : _timestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [type, message, _timestamp];
}

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardUIAction? uiAction;
  final String? globalError;

  final String quote;
  final List<Task> alltasks;
  final List<Task> filteredTasks;
  final FilterModel currentFilters;
  final String? highlightedTaskId;
  final int currentTaskIndex;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.uiAction,
    this.globalError,
    this.quote = '"Keep pushing forward." - Unknown',
    this.alltasks = const [],
    this.filteredTasks = const [],
    this.currentFilters = const FilterModel(),
    this.currentTaskIndex = 0,
    this.highlightedTaskId,
  });

  @override
  List<Object?> get props => [
    status,
    uiAction,
    globalError,
    quote,
    alltasks,
    filteredTasks,
    currentFilters,
    highlightedTaskId,
    currentTaskIndex,
  ];

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardUIAction? uiAction,
    String? globalError,
    String? quote,
    List<Task>? alltasks,
    List<Task>? filteredTasks,
    FilterModel? currentFilters,
    int? currentTaskIndex,
    String? highlightedTaskId,
  }) {
    return DashboardState(
      status: status ?? this.status,
      uiAction: uiAction,
      globalError: globalError ?? this.globalError,
      quote: quote ?? this.quote,
      alltasks: alltasks ?? this.alltasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      currentFilters: currentFilters ?? this.currentFilters,
      currentTaskIndex: currentTaskIndex ?? this.currentTaskIndex,
      highlightedTaskId: highlightedTaskId ?? this.highlightedTaskId,
    );
  }
}
