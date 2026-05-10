import 'package:flutter/material.dart';
import 'package:task_app/core/theme/app_pallete.dart' show AppPallete;
import 'animated_gradient_text.dart';

class HeroTitle extends StatefulWidget {
  final ThemeData theme;

  const HeroTitle({super.key, required this.theme});

  @override
  State<HeroTitle> createState() => _HeroTitleState();
}

class _HeroTitleState extends State<HeroTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // final isLarge = size.width > 900;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 15.0,
      runSpacing: 8.0,
      children: [
        Text(
          'Boost Productivity',
          style: widget.theme.textTheme.displayMedium?.copyWith(
            color: widget.theme.dividerColor,
          ),
        ),
        Text('with', style: widget.theme.textTheme.displayMedium),

        AnimatedGradientText(
          text: 'Klarity',
          colors: const [
            AppPallete.primaryMain,
            AppPallete.warningMain,
            AppPallete.primaryMain,
            AppPallete.warningMain,
            AppPallete.primaryMain,
          ],
          animation: _controller,
          style: widget.theme.textTheme.displayMedium,
        ),
      ],
    );
  }
}
