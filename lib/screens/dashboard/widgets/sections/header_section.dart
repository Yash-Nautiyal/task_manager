import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:task_app/models/task_model.dart';
import '../../../../models/filter_model.dart';
import '../db_add_button.dart';
import '../db_filters.dart';
import '../db_header.dart';

class HeaderSection extends StatelessWidget {
  final ThemeData theme;
  final AnimationController controller;
  final User? user;
  final List<Task> allTasks;
  final FilterModel currentFilters;
  final VoidCallback showAddTaskDialog;
  const HeaderSection({
    super.key,
    required this.theme,
    required this.controller,
    required this.user,
    required this.allTasks,
    required this.currentFilters,
    required this.showAddTaskDialog,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ).copyWith(top: 130),
        child: Column(
          children: [
            const SizedBox(height: 10),
            DbHeader(
              theme: theme,
              controller: controller,
              userFirstName:
                  user != null
                      ? '${user?.displayName?.toString().split(' ')[0].toString()}'
                      : '',
            ),
            const SizedBox(height: 20),
            DbFilters(
              theme: theme,
              allTasks: allTasks,
              currentFilters: currentFilters,
              onFiltersChanged: (newFilters) {},
            ),
            DbAddButton(
              theme: theme,
              onPressed: () => showAddTaskDialog.call(),
            ),
          ],
        ),
      ),
    );
  }
}
