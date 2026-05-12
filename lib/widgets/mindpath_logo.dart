import 'package:flutter/material.dart';

class MindPathLogoMark extends StatelessWidget {
  const MindPathLogoMark({super.key, required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(108, 108),
            painter: ArcRingPainter(color: primary),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 66,
              height: 66,
              child: Icon(Icons.spa_rounded, color: primary, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class MindPathWordmark extends StatelessWidget {
  const MindPathWordmark({super.key, required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: primary,
        ),
        children: [
          const TextSpan(text: 'Mind'),
          TextSpan(
            text: 'Path',
            style: TextStyle(color: primary.withValues(alpha: 0.86)),
          ),
        ],
      ),
    );
  }
}

class ArcRingPainter extends CustomPainter {
  ArcRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    const gapAngle = 0.55;
    const startAngle = -1.2;
    final sweepAngle = (3.1415926535897932 * 2) - gapAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ArcRingPainter oldDelegate) => oldDelegate.color != color;
}

