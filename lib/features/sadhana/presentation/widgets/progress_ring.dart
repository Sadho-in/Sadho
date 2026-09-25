import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular progress ring with centred text. Used on the Sadhana tab and in
/// Focus mode.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.primaryText,
    required this.secondaryText,
    this.size = 260,
    this.strokeWidth = 16,
    this.completed = false,
    this.activeColor,
  });

  final double progress;
  final String primaryText;
  final String secondaryText;
  final double size;
  final double strokeWidth;
  final bool completed;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color =
        activeColor ?? (completed ? scheme.secondary : scheme.primary);

    return Semantics(
      label: '$primaryText, $secondaryText',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animate the sweep so single taps and rhythm ticks glide.
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (_, value, _) => CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  trackColor: scheme.surfaceContainerHighest,
                  color: color,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(strokeWidth + 12),
              // The count and the line under it fit inside the ring together
              // (each already fits its width), even at a very large text size.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        primaryText,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: size * 0.2,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        secondaryText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.color,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arc, 0, math.pi * 2, false, paint..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(
        arc,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
