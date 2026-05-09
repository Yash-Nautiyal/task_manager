import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';

class DbAddButton extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback? onPressed;

  const DbAddButton({super.key, required this.theme, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => onPressed?.call(),
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          backgroundColor: WidgetStateProperty.all(theme.primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppPallete.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '  Add Task',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppPallete.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
