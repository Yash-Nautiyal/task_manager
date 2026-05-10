import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_app/core/theme/app_pallete.dart';

class HomeMinimal extends StatelessWidget {
  final ThemeData theme;
  const HomeMinimal({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header text
          Text(
            'VISUALIZING SUCCESS',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "What's in ",
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              Text(
                "Klarity?",
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  foreground:
                      Paint()
                        ..shader = const LinearGradient(
                          colors: [AppPallete.white, AppPallete.grey800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 500.0, 120.0),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Feature items
          FeatureItem(
            image: 'assets/icons/ic-line-chart.svg',
            title: 'Effortless Task Management',
            description:
                'Add, organize, and prioritize your tasks with a single click. Stay on top of your day with a clean, distraction-free interface.',
            theme: theme,
          ),
          const SizedBox(height: 24),

          FeatureItem(
            image: 'assets/icons/ic-clock-outline.svg',
            title: 'Overdue Reminders',
            description:
                'Get instantly notified when a task becomes overdue, so you never miss important deadlines.',
            theme: theme,
          ),
          const SizedBox(height: 24),

          FeatureItem(
            image: 'assets/icons/ic-chart-bar.svg',
            title: 'Productivity Insights',
            description:
                'Track your progress and see your productivity trends with beautiful, built-in analytics.',
            theme: theme,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final ThemeData theme;
  const FeatureItem({
    super.key,
    required this.image,
    required this.title,
    required this.theme,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          image,
          width: 35,
          height: 35,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.tertiary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
