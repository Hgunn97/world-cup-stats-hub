import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(40), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
