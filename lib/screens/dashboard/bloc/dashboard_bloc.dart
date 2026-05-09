import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_app/core/error/failures.dart';
import 'package:task_app/core/helpers/task_helpers.dart';
import 'package:task_app/services/firestore_service.dart';

import '../../../models/filter_model.dart';
import '../../../models/task_model.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      super(DashboardInitial()) {
    on<DashboardLoadTasksEvent>(_onLoadTasks);
    on<DashboardAddTaskEvent>(_onAddTask);
    on<DashboardUpdateTaskEvent>(_onUpdateTask);
    on<DashboardDeleteTaskEvent>(_onDeleteTask);
    on<DashboardHighlightTaskEvent>(_onHighlightTask);
    on<DashboardUpdateFiltersEvent>(_onFilterChanged);
    on<DashboardTabChangedEvent>(_onTabChanged);
    on<DashboardUpdateTaskStatusEvent>(_onUpdateTaskStatus);
    on<_DashboardTasksChanged>(_onTasksChanged);
  }

  final FirestoreService _firestoreService;
  StreamSubscription<List<Task>>? _tasksSubscription;

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
    emit(DashboardLoadingState());
    await _tasksSubscription?.cancel();
    try {
      _tasksSubscription = _firestoreService.getTasksStream(event.userId).listen(
        (tasks) => add(_DashboardTasksChanged(tasks)),
      );
    } on AppFailure catch (e) {
      emit(DashboardDataErrorState(error: e.message));
    } catch (_) {
      emit(
        DashboardDataErrorState(
          error: 'Failed to load tasks. Please check your connection.',
        ),
      );
    }
  }

  Future<void> _onAddTask(
    DashboardAddTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await _firestoreService.addTask(event.task);
      emit(DashboardDataSucssfulState(successMessage: 'Task added successfully.'));
    } on AppFailure catch (e) {
      emit(DashboardDataErrorState(error: e.message));
    } catch (_) {
      emit(
        DashboardDataErrorState(
          error: 'Failed to add task. Please check your connection.',
        ),
      );
    }
  }

  Future<void> _onUpdateTask(
    DashboardUpdateTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await _firestoreService.editTask(event.task);
      emit(
        DashboardDataSucssfulState(successMessage: 'Task updated successfully.'),
      );
    } on AppFailure catch (e) {
      emit(DashboardDataErrorState(error: e.message));
    } catch (_) {
      emit(
        DashboardDataErrorState(
          error: 'Failed to update task. Please check your connection.',
        ),
      );
    }
  }

  Future<void> _onDeleteTask(
    DashboardDeleteTaskEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await _firestoreService.deleteTask(event.taskId);
      emit(
        DashboardDataSucssfulState(successMessage: 'Task deleted successfully.'),
      );
    } on AppFailure catch (e) {
      emit(DashboardDataErrorState(error: e.message));
    } catch (_) {
      emit(
        DashboardDataErrorState(
          error: 'Failed to delete task. Please check your connection.',
        ),
      );
    }
  }

  void _onHighlightTask(
    DashboardHighlightTaskEvent event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardDataLoadedState) {
      final currentState = state as DashboardDataLoadedState;
      emit(currentState.copyWith(highlightedTaskId: event.highlightedTaskId));
    }
  }

  void _onFilterChanged(
    DashboardUpdateFiltersEvent event,
    Emitter<DashboardState> emit,
  ) {
    if (state is! DashboardDataLoadedState) return;
    final currentState = state as DashboardDataLoadedState;
    final filteredTasks = _buildFilteredTasks(
      allTasks: currentState.alltasks,
      filters: event.filters,
      tabIndex: currentState.currentTaskIndex,
    );
    emit(
      currentState.copyWith(
        currentFilters: event.filters,
        filteredTasks: filteredTasks,
      ),
    );
  }

  void _onTabChanged(
    DashboardTabChangedEvent event,
    Emitter<DashboardState> emit,
  ) {
    if (state is! DashboardDataLoadedState) return;
    final currentState = state as DashboardDataLoadedState;
    final filteredTasks = _buildFilteredTasks(
      allTasks: currentState.alltasks,
      filters: currentState.currentFilters,
      tabIndex: event.tabIndex,
    );
    emit(
      currentState.copyWith(
        currentTaskIndex: event.tabIndex,
        filteredTasks: filteredTasks,
      ),
    );
  }

  FutureOr<void> _onUpdateTaskStatus(
    DashboardUpdateTaskStatusEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      if (event.isCompleted) {
        await _firestoreService.markTaskAsCompleted(event.taskId);
        emit(DashboardTaskCompletedState());
      } else {
        if (state is! DashboardDataLoadedState) {
          throw const FirestoreFailure('Task data is not loaded yet.');
        }
        final currentState = state as DashboardDataLoadedState;
        final existingTask = currentState.alltasks.where(
          (task) => task.id == event.taskId,
        );
        if (existingTask.isEmpty) {
          throw const FirestoreFailure('Task not found.');
        }
        await _firestoreService.editTask(
          existingTask.first.copyWith(
            status: TaskStatus.todo,
            completedAt: null,
          ),
        );
      }
    } on AppFailure catch (e) {
      emit(DashboardDataErrorState(error: e.message));
    } catch (_) {
      emit(
        DashboardDataErrorState(
          error: 'Failed to update task status. Please check your connection.',
        ),
      );
    }
  }

  void _onTasksChanged(
    _DashboardTasksChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardDataLoadedState) {
      final currentState = state as DashboardDataLoadedState;
      final filteredTasks = _buildFilteredTasks(
        allTasks: event.tasks,
        filters: currentState.currentFilters,
        tabIndex: currentState.currentTaskIndex,
      );
      emit(
        currentState.copyWith(alltasks: event.tasks, filteredTasks: filteredTasks),
      );
      return;
    }

    const defaultFilters = FilterModel();
    const defaultTab = 0;
    final filteredTasks = _buildFilteredTasks(
      allTasks: event.tasks,
      filters: defaultFilters,
      tabIndex: defaultTab,
    );
    emit(
      DashboardDataLoadedState(
        alltasks: event.tasks,
        filteredTasks: filteredTasks,
        currentFilters: defaultFilters,
        currentTaskIndex: defaultTab,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _tasksSubscription?.cancel();
    return super.close();
  }
}

class _DashboardTasksChanged extends DashboardEvent {
  const _DashboardTasksChanged(this.tasks);

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];
}
