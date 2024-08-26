import 'package:flutter/material.dart';

class WavyBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Path path = Path();
    double waveHeight = 20; // Increase height for more visible waves
    double waveLength = 40; // Decrease length for shorter waves

    // Starting point for the wave
    path.moveTo(0, size.height * 0.25);

    // Draw the wavy border
    for (double x = 0; x <= size.width; x += waveLength / 2) {
      path.lineTo(x, size.height * 0.25 + waveHeight * ((x / waveLength).floor() % 2 == 0 ? 1 : -1));
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
