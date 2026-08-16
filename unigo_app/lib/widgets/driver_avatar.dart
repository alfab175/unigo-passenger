import 'package:flutter/material.dart';

/// Round profile avatar that prefers a real photo (from the driver app) and
/// falls back to a clean line-drawn portrait: white fill, black pen outline,
/// with ear and hair detail. A male variant is drawn when [male] is true.
class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.male = true,
    this.radius = 26,
  });

  final String? photoUrl;
  final String? name;
  final bool male;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: Colors.transparent,
      );
    }
    final d = radius * 2;
    return SizedBox(
      width: d,
      height: d,
      child: CustomPaint(painter: _LinePortraitPainter(male: male)),
    );
  }
}

class _LinePortraitPainter extends CustomPainter {
  _LinePortraitPainter({required this.male});
  final bool male;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = Colors.white;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Clip to circle and fill background.
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: cx)));
    canvas.drawRect(Offset.zero & size, fill);

    // Ears.
    final earRy = cy + size.height * 0.02;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - size.width * 0.26, earRy), width: size.width * 0.12, height: size.height * 0.16), stroke);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + size.width * 0.26, earRy), width: size.width * 0.12, height: size.height * 0.16), stroke);

    // Head outline.
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + size.height * 0.02), width: size.width * 0.52, height: size.height * 0.6), stroke);

    // Hair: short cap for male, longer sides for female.
    final hair = Path();
    if (male) {
      hair
        ..moveTo(cx - size.width * 0.22, cy - size.height * 0.16)
        ..quadraticBezierTo(cx, cy - size.height * 0.34, cx + size.width * 0.22, cy - size.height * 0.16)
        ..quadraticBezierTo(cx + size.width * 0.18, cy - size.height * 0.22, cx + size.width * 0.06, cy - size.height * 0.2)
        ..quadraticBezierTo(cx, cy - size.height * 0.24, cx - size.width * 0.06, cy - size.height * 0.2)
        ..quadraticBezierTo(cx - size.width * 0.18, cy - size.height * 0.22, cx - size.width * 0.22, cy - size.height * 0.16);
    } else {
      hair
        ..moveTo(cx - size.width * 0.26, cy + size.height * 0.1)
        ..quadraticBezierTo(cx - size.width * 0.34, cy - size.height * 0.2, cx, cy - size.height * 0.32)
        ..quadraticBezierTo(cx + size.width * 0.34, cy - size.height * 0.2, cx + size.width * 0.26, cy + size.height * 0.1);
    }
    canvas.drawPath(hair, stroke);

    // Eyes.
    final eyeY = cy + size.height * 0.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - size.width * 0.1, eyeY), width: size.width * 0.05, height: size.height * 0.06), stroke);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + size.width * 0.1, eyeY), width: size.width * 0.05, height: size.height * 0.06), stroke);

    // Nose.
    final nose = Path()
      ..moveTo(cx, eyeY + size.height * 0.04)
      ..quadraticBezierTo(cx - size.width * 0.03, cy + size.height * 0.14, cx, cy + size.height * 0.16)
      ..quadraticBezierTo(cx + size.width * 0.03, cy + size.height * 0.14, cx, eyeY + size.height * 0.04);
    canvas.drawPath(nose, stroke);

    // Mouth.
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + size.height * 0.24), width: size.width * 0.16, height: size.height * 0.1), 0.15, 3.14, false, stroke);
  }

  @override
  bool shouldRepaint(covariant _LinePortraitPainter old) => old.male != male;
}
