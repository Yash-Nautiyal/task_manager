import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_app/core/helpers/task_helpers.dart';
import 'package:task_app/core/utils/result.dart';
import 'package:task_app/services/firestore_service.dart';
import 'package:task_app/services/api_service.dart'; // Added API Service

import '../../../models/filter_model.dart';
import '../../../models/task_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({FirestoreService? firestoreService, ApiService? apiService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      _apiService = apiService ?? ApiService(),
      super(DashboardInitial()) {
    on<DashboardLoadTasksEvent>(_onLoadTasks);
    on<DashboardAddTaskEvent>(_onAddTask);
    on<DashboardUpdateTaskEvent>(_onUpdateTask);
    on<DashboardDeleteTaskEvent>(_onDeleteTask);
    on<DashboardHighlightTaskEvent>(_onHighlightTask);
    on<DashboardUpdateFiltersEvent>(_onFilterChanged);
    on<DashboardUpdateTaskListFiltersEvent>(_onTaskListFiltersChanged);
    on<DashboardTabChangedEvent>(_onTabChanged);
    on<DashboardUpdateTaskStatusEvent>(_onUpdateTaskStatus);
    on<_DashboardTasksChanged>(_onTasksChanged);
    on<DashboardFetchQuoteEvent>(_onFetchQuote);
    on<DashboardUpdateTaskListStatusFilterEvent>(
      _onTaskListStatusFilterChanged,
    );
  }

  final FirestoreService _firestoreService;
  final ApiService _apiService;
  StreamSubscription<List<Task>>? _tasksSubscription;

  String _currentQuote =
      '"The secret of getting ahead is getting started." - Mark Twain';

  List<Task> _buildFilteredTasks({
    required List<Task> allTasks,
    required FilterModel filters,
    required int tabIndex,
  }) {
    final sortedTasks = getSortedTasks(allTasks);
    return applyFilters(sortedTasks, filters, tabIndex: tabIndex);
  }

  Future<void> _onLoadTasks(
    DashboardLoadTasksEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    add(DashboardFetchQuoteEvent());

    await _tasksSubscription?.cancel();
    try {
      _tasksSubscription = _firestoreService
          .getTasksStream(event.userId)
          .listen((tasks) => add(_DashboardTasksChanged(tasks)));
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          globalError: 'Failed to load tasks. Please check your connection.',
        ),
      );
    }
  }

  void _onTasksChanged(
    _DashboardTasksChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(
      state.copyWith(
        status: DashboardStatus.loaded,
        alltasks: event.tasks,
        filteredTasks: _buildFilteredTasks(
          allTasks: event.tasks,
          filters: state.currentFilters,
          tabIndex: state.currentTaskIndex,
        ),
      ),
    );
  }

  Future<void> _onFetchQuote(
    DashboardFetchQuoteEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final response = await _apiService.fetchRandomQuote();

    if (response.isSuccess) {
      _currentQuote = response.data!;
      emit(state.copyWith(quote: _currentQuote));
    } else {
      emit(state.copyWith(quote: _currentQuote));
      // emit(
      //   state.copyWith(
      //     quote: _currentQuote,
      //     uiAction: DashboardUIAction(
      //       type: UIActionType.error,
      //       message: response.failure!.message,
      //     ),
      //   ),
      // );
      debugPrint('Failed to fetch quote: ${response.failure!.message}');
    }
  }

  Future<void> _onAddTask(
    DashboardAddTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await _firestoreService.addTask(event.task);
    if (result.isSuccess) {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.success,
            message: 'Task added successfully.',
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.error,
            message: result.failure!.message,
          ),
        ),
      );
    }
  }

  Future<void> _onUpdateTask(
    DashboardUpdateTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final updatedTasks =
        state.alltasks
            .map((t) => t.id == event.task.id ? event.task : t)
            .toList();
    emit(
      state.copyWith(
        alltasks: updatedTasks,
        filteredTasks: _buildFilteredTasks(
          allTasks: updatedTasks,
          filters: state.currentFilters,
          tabIndex: state.currentTaskIndex,
        ),
      ),
    );

    // 2. Background Database Update
    final result = await _firestoreService.editTask(event.task);
    if (result.isSuccess) {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.success,
            message: 'Task updated',
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.error,
            message: result.failure!.message,
          ),
        ),
      );
    }
  }

  Future<void> _onDeleteTask(
    DashboardDeleteTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final updatedTasks =
        state.alltasks.where((t) => t.id != event.taskId).toList();

    emit(
      state.copyWith(
        alltasks: updatedTasks,
        filteredTasks: _buildFilteredTasks(
          allTasks: updatedTasks,
          filters: state.currentFilters,
          tabIndex: state.currentTaskIndex,
        ),
      ),
    );

    final result = await _firestoreService.deleteTask(event.taskId);

    if (result.isSuccess) {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.success,
            message: 'Task deleted successfully.',
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.error,
            message: result.failure!.message,
          ),
        ),
      );
    }
  }

  void _onHighlightTask(
    DashboardHighlightTaskEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(highlightedTaskId: event.highlightedTaskId));
  }

  void _onFilterChanged(
    DashboardUpdateFiltersEvent event,
    Emitter<DashboardState> emit,
  ) {
    final filteredTasks = _buildFilteredTasks(
      allTasks: state.alltasks,
      filters: event.filters,
      tabIndex: state.currentTaskIndex,
    );
    emit(
      state.copyWith(
        currentFilters: event.filters,
        filteredTasks: filteredTasks,
      ),
    );
  }

  void _onTabChanged(
    DashboardTabChangedEvent event,
    Emitter<DashboardState> emit,
  ) {
    final filteredTasks = _buildFilteredTasks(
      allTasks: state.alltasks,
      filters: state.currentFilters,
      tabIndex: event.tabIndex,
    );
    emit(
      state.copyWith(
        currentTaskIndex: event.tabIndex,
        filteredTasks: filteredTasks,
      ),
    );
  }

  FutureOr<void> _onUpdateTaskStatus(
    DashboardUpdateTaskStatusEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // 1. Optimistic Update
    final updatedTasks =
        state.alltasks.map((t) {
          if (t.id == event.taskId) {
            return t.copyWith(
              status:
                  event.isCompleted ? TaskStatus.completed : TaskStatus.todo,
              completedAt: event.isCompleted ? DateTime.now() : null,
            );
          }
          return t;
        }).toList();

    emit(
      state.copyWith(
        alltasks: updatedTasks,
        filteredTasks: _buildFilteredTasks(
          allTasks: updatedTasks,
          filters: state.currentFilters,
          tabIndex: state.currentTaskIndex,
        ),
      ),
    );

    // 2. Background Sync
    Result<void> result;
    if (event.isCompleted) {
      result = await _firestoreService.markTaskAsCompleted(event.taskId);
    } else {
      final existingTask = state.alltasks.firstWhere(
        (t) => t.id == event.taskId,
      );
      result = await _firestoreService.editTask(
        existingTask.copyWith(status: TaskStatus.todo, completedAt: null),
      );
    }

    // 3. Side Effects
    if (result.isSuccess) {
      if (event.isCompleted) {
        // Triggers Confetti without losing the state!
        emit(
          state.copyWith(
            uiAction: DashboardUIAction(type: UIActionType.confetti),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          uiAction: DashboardUIAction(
            type: UIActionType.error,
            message: result.failure!.message,
          ),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onTaskListFiltersChanged(
    DashboardUpdateTaskListFiltersEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(taskListFilters: event.filters));
  }

  FutureOr<void> _onTaskListStatusFilterChanged(
    DashboardUpdateTaskListStatusFilterEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(taskListStatusFilter: event.statusFilter));
  }
}

class _DashboardTasksChanged extends DashboardEvent {
  const _DashboardTasksChanged(this.tasks);

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];
}
