import 'package:flutter/material.dart';

class EmptyTasks extends StatelessWidget {
  const EmptyTasks({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Yay! No tasks here. Grab a coffee and relax ☕',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.disabledColor,
        ),
      ),
    );
  }
}
