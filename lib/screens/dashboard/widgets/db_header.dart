import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart';

import '../../home/widgets/animated_gradient_text.dart';

class DbHeader extends StatelessWidget {
  final ThemeData theme;
  final Animation<double> controller;
  final String userFirstName;
  final String quote;
  const DbHeader({
    super.key,
    required this.theme,
    required this.controller,
    required this.userFirstName,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedGradientText(
          text: 'Hello, $userFirstName!',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppPallete.white,
            fontWeight: FontWeight.bold,
          ),
          animation: controller,
          colors: [
            AppPallete.warningMain,
            AppPallete.primaryMain,
            AppPallete.infoMain,
          ],
        ),
        const SizedBox(height: 10),
        Text(
          quote,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
