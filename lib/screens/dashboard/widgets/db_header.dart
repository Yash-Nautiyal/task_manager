import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';

import '../../home/widgets/animated_gradient_text.dart';

class DbHeader extends StatelessWidget {
  final ThemeData theme;
  final Animation<double> controller;
  final String userFirstName;
  const DbHeader({
    super.key,
    required this.theme,
    required this.controller,
    required this.userFirstName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('🙏', style: theme.textTheme.displayLarge?.copyWith(fontSize: 50)),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: [
            Text('Namaste', style: theme.textTheme.displayMedium),
            AnimatedGradientText(
              text:
                  userFirstName.isNotEmpty
                      ? '${userFirstName[0].toUpperCase()}${userFirstName.substring(1)}'
                      : '',
              colors: const [
                AppPallete.secondaryLight,
                AppPallete.infoMain,
                AppPallete.infoMain,
                AppPallete.secondaryLight,
                AppPallete.infoMain,
              ],
              animation: controller,
              style: theme.textTheme.displayMedium,
            ),
          ],
        ),
        Text(
          'What are we ticking off today?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}
