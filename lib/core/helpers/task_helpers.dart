import 'dart:ui';

import 'package:task_app/models/filter_model.dart';

import '../../models/task_model.dart';
import '../theme/app_pallete.dart';

extension TaskStatusColorExtension on TaskStatus {
  Color get color => switch (this) {
    TaskStatus.todo => AppPallete.primaryMain,
    TaskStatus.completed => AppPallete.successMain,
    TaskStatus.overdue => AppPallete.errorMain,
  };
}

List<Task> getSortedTasks(List<Task> tasks) {
  return List<Task>.from(tasks)..sort((a, b) {
    if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) {
      return 1;
    }
    if (b.status == TaskStatus.completed && a.status != TaskStatus.completed) {
      return -1;
    }
    return a.dueDate.compareTo(b.dueDate);
  });
}

List<Task> getFilteredTasks(int tabIndex, List<Task> sortedTasks) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final weekEnd = today
      .subtract(Duration(days: today.weekday - 1))
      .add(const Duration(days: 7));
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  switch (tabIndex) {
    case 0: // Today
      return sortedTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isBefore(today.add(const Duration(days: 1))) &&
            task.status != TaskStatus.completed;
      }).toList();
    case 1: // Tomorrow
      return sortedTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isBefore(tomorrow.add(const Duration(days: 1))) &&
            task.status != TaskStatus.completed;
      }).toList();
    case 2: // This Week
      return sortedTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isBefore(weekEnd) &&
            task.status != TaskStatus.completed;
      }).toList();
    case 3: // This Month
      return sortedTasks.where((task) {
        final taskDate = DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
        );
        return taskDate.isBefore(monthEnd) &&
            task.status != TaskStatus.completed;
      }).toList();
    case 4: // Completed
      return sortedTasks
          .where((task) => task.status == TaskStatus.completed)
          .toList()
        ..sort((a, b) {
          // Sort completed tasks by most recent due date first
          return b.dueDate.compareTo(a.dueDate);
        });
    default:
      return sortedTasks;
  }
}

List<Task> applyFilters(
  List<Task> tasks,
  FilterModel filters, {
  int tabIndex = 0,
}) {
  List<Task> filtered = getFilteredTasks(tabIndex, tasks);

  if (filters.searchQuery.isNotEmpty) {
    filtered =
        filtered
            .where(
              (task) =>
                  task.title.toLowerCase().contains(
                    filters.searchQuery.toLowerCase(),
                  ) ||
                  task.description.toLowerCase().contains(
                    filters.searchQuery.toLowerCase(),
                  ),
            )
            .toList();
  }

  if (filters.startDate != null && filters.endDate != null) {
    filtered =
        filtered
            .where(
              (task) =>
                  task.dueDate.isAfter(
                    filters.startDate!.subtract(const Duration(days: 1)),
                  ) &&
                  task.dueDate.isBefore(
                    filters.endDate!.add(const Duration(days: 1)),
                  ),
            )
            .toList();
  }

  return filtered;
}
