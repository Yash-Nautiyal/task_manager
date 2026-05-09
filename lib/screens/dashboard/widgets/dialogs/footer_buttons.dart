import 'package:flutter/material.dart';
import 'package:task_app/widgets/common/button/custom_textbutton.dart';

class FooterButtons extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback createTask;
  final bool isEdit;
  const FooterButtons({
    super.key,
    required this.theme,
    required this.createTask,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        CustomTextButton(
          child: Text(
            "Cancel",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          onClick: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        CustomTextButton(
          backgroundColor: theme.colorScheme.tertiary,
          onClick: createTask,
          child: Text(
            isEdit ? "Update Task" : "Create Task",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.scaffoldBackgroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
