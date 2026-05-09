import 'package:flutter/material.dart';

import 'package:task_app/models/task_model.dart';
import '../charts/task_distribution_chart.dart';

class ChartSection extends StatelessWidget {
  final ThemeData theme;
  final List<Task> tasks;
  final Function(int, String?) onPageChanged;

  const ChartSection({
    super.key,
    required this.theme,
    required this.tasks,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ).copyWith(bottom: 20),
        child: Column(
          children: [
            TaskDistributionChart(
              tasks: tasks,
              navigationToTaskList: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}
