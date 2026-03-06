import 'package:flutter/material.dart';

class ToothPainter extends CustomPainter {
  final Color color;
  final bool isUpper;

  ToothPainter({required this.color, required this.isUpper});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    Paint paint = Paint()..color = color..style = PaintingStyle.fill;
    Paint borderPaint = Paint()..color = Colors.black.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2;

    Path path = Path();
    if (isUpper) {
      path.moveTo(w * 0.2, h * 0.1);
      path.quadraticBezierTo(w * 0.5, 0, w * 0.8, h * 0.1);
      path.lineTo(w * 0.9, h * 0.6);
      path.quadraticBezierTo(w, h * 0.95, w * 0.7, h);
      path.lineTo(w * 0.3, h);
      path.quadraticBezierTo(0, h * 0.95, w * 0.1, h * 0.6);
    } else {
      path.moveTo(w * 0.3, 0);
      path.lineTo(w * 0.7, 0);
      path.quadraticBezierTo(w, h * 0.05, w * 0.9, h * 0.4);
      path.lineTo(w * 0.8, h * 0.9);
      path.quadraticBezierTo(w * 0.5, h, w * 0.2, h * 0.9);
      path.lineTo(w * 0.1, h * 0.4);
      path.quadraticBezierTo(0, h * 0.05, w * 0.3, 0);
    }
    path.close();
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 2, false);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}