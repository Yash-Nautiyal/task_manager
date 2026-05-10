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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.dividerColor.withAlpha(65)
                  : theme.dividerColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.tertiary
                        : theme.dividerColor.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? theme.scaffoldBackgroundColor
                        : theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color:
                      isSelected
                          ? theme.colorScheme.tertiary
                          : theme.dividerColor.withValues(alpha: 0.5),
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
