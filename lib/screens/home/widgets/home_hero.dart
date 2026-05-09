import 'package:flutter/material.dart';

import 'hero_title.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.65,
          width: double.infinity,
          child: Image.asset('assets/images/Bg.png', fit: BoxFit.cover),
        ),
        // Content overlay
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with gradient text
                  HeroTitle(theme: theme),

                  // Subtitle
                  const SizedBox(height: 24),
                  Text(
                    'Minimalistic and lightweight, it helps you stay focused and get things done. Remove all the complex todo applications fuss and try out 2DOO today for free!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 50,
          right: 50,
          top: 50,
          bottom: 50,
          child: Image.asset('assets/images/dots.png', fit: BoxFit.contain),
        ),
      ],
    );
  }
}
