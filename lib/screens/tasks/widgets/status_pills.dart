// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const StatusPill({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final activeBg =
        isDark
            ? Colors.white.withOpacity(0.12)
            : theme.colorScheme.primary.withOpacity(0.10);
    final inactiveBg =
        isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04);

    final activeFg = theme.colorScheme.tertiary;
    final inactiveFg =
        isDark
            ? Colors.white.withOpacity(0.38)
            : Colors.black.withOpacity(0.35);

    final badgeBg =
        isSelected
            ? activeFg.withOpacity(0.14)
            : (isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeFg.withOpacity(0.30) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? activeFg : inactiveFg,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),

            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 22, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? activeFg : inactiveFg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
