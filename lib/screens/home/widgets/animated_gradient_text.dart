import 'package:flutter/material.dart';

class AnimatedGradientText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? style;
  final Animation<double> animation;

  const AnimatedGradientText({
    super.key,
    required this.text,
    required this.colors,
    this.style,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Text(
          text,
          style: style?.copyWith(
            foreground:
                Paint()
                  ..shader = LinearGradient(
                    colors: colors,
                    stops: List.generate(
                      colors.length,
                      (index) => index / (colors.length - 1),
                    ),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: SlidingGradientTransform(
                      translation: animation.value,
                    ),
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 220.0, 70.0)),
          ),
        );
      },
    );
  }
}

class SlidingGradientTransform extends GradientTransform {
  const SlidingGradientTransform({required this.translation});

  final double translation;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * translation, 0.0, 0.0);
  }
}
