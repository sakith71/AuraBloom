import 'package:flutter/material.dart';
import 'dart:math';

class CalendarDay extends StatelessWidget {
  final String day;
  final bool isSelected;
  final bool isEnabled;
  final bool isPastOrToday;
  final bool isToday;
  final bool isPredicted;
  final Function()? onTap;

  const CalendarDay({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isEnabled,
    required this.isPastOrToday,
    required this.isToday,
    this.isPredicted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base container for the day
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSelected
                      ? const Color.fromARGB(255, 255, 233, 242)
                      : isToday
                      ? Colors.red.withOpacity(0.1)
                      : Colors.transparent,
              border:
                  isSelected
                      ? Border.all(
                        color: const Color.fromARGB(255, 240, 99, 153),
                        width: 2,
                      )
                      : isToday
                      ? Border.all(color: Colors.red, width: 1)
                      : null,
            ),
            child: Text(
              day,
              style: TextStyle(
                color:
                    !isEnabled || !isPastOrToday
                        ? Colors.grey.shade300
                        : isSelected
                        ? const Color.fromARGB(255, 240, 99, 153)
                        : isToday
                        ? Colors.red
                        : Colors.black87,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Prediction indicator - dotted border with center dot
          if (isPredicted && isEnabled && !isSelected && day.isNotEmpty)
            CustomPaint(
              size: const Size(30, 30),
              painter: DottedCirclePainter(
                color: const Color.fromARGB(255, 240, 99, 153),
                dotRadius: 1.0,
                circleRadius: 15,
                numberOfDots: 12,
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter to draw a dotted circle around predicted dates
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double circleRadius;
  final int numberOfDots;

  DottedCirclePainter({
    required this.color,
    required this.dotRadius,
    required this.circleRadius,
    required this.numberOfDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw the circle of dots
    final angleStep = 2 * 3.14159 / numberOfDots;
    for (int i = 0; i < numberOfDots; i++) {
      final angle = i * angleStep;
      final dotCenter = Offset(
        center.dx + circleRadius * cos(angle),
        center.dy + circleRadius * sin(angle),
      );
      canvas.drawCircle(dotCenter, dotRadius, paint);
    }

    // Draw a small dot in the center
    canvas.drawCircle(center, 1.5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
