import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Gradient gradient;
  final double radius;
  final Paint paintObject;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.gradient,
    required this.radius,
  }) : paintObject = Paint()
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final Paint paint = paintObject..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GradientBorderContainer extends StatelessWidget {
  final double strokeWidth;
  final Gradient gradient;
  final double radius;
  final Widget child;

  const GradientBorderContainer({
    Key? key,
    required this.strokeWidth,
    required this.gradient,
    required this.radius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: GradientBorderPainter(
            strokeWidth: strokeWidth,
            gradient: gradient,
            radius: radius,
          ),
          child: Container(),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: EdgeInsets.all(strokeWidth),
            child: child,
          ),
        ),
      ],
    );
  }
}
