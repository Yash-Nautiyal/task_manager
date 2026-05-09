import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_app/models/task_model.dart';
import 'calendar_overlay_task_item.dart';

class TaskOverlay extends StatelessWidget {
  final ThemeData theme;
  final DateTime selectedDay;
  final List<Task> tasks;
  final VoidCallback onClose;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Function(int, String?) navigateToTaskList;

  const TaskOverlay({
    super.key,
    required this.theme,
    required this.selectedDay,
    required this.tasks,
    required this.onClose,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.navigateToTaskList,
  });

  @override
  Widget build(BuildContext context) {
    tasks.sort((a, b) {
      int getOrder(Task t) {
        switch (t.status) {
          case TaskStatus.overdue:
            return 0;

          case TaskStatus.todo:
            return 2;
          case TaskStatus.completed:
            return 3;
        }
      }

      return getOrder(a).compareTo(getOrder(b));
    });
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping the container
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.9,
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/common/solid/ic-solar-calendar-mark-bold-duotone.svg',
                        color: theme.disabledColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tasks for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.disabledColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryFixedDim.withOpacity(
                            theme.brightness == Brightness.dark ? 0.1 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child:
                        tasks.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No tasks for this date',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                return CalendarOverlayTaskItem(
                                  task: tasks[index],
                                  theme: theme,
                                  onTaskSelected: navigateToTaskList,
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
