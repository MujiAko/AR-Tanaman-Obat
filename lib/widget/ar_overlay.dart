import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Empat sudut bingkai bidik, seperti viewfinder pada referensi desain AR.
class BracketPainter extends CustomPainter {
  final Rect frame;
  final Color color;

  const BracketPainter({required this.frame, this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const arm = 34.0;
    const r = 14.0;
    final l = frame.left, t = frame.top, rt = frame.right, b = frame.bottom;

    Path corner(double x, double y, double dx, double dy) {
      // dx/dy = arah ke dalam bingkai (+1 / -1)
      return Path()
        ..moveTo(x, y + dy * arm)
        ..lineTo(x, y + dy * r)
        ..quadraticBezierTo(x, y, x + dx * r, y)
        ..lineTo(x + dx * arm, y);
    }

    canvas.drawPath(corner(l, t, 1, 1), paint);
    canvas.drawPath(corner(rt, t, -1, 1), paint);
    canvas.drawPath(corner(l, b, 1, -1), paint);
    canvas.drawPath(corner(rt, b, -1, -1), paint);
  }

  @override
  bool shouldRepaint(BracketPainter old) =>
      old.frame != frame || old.color != color;
}

/// Label mengambang di atas objek: teks + garis penunjuk + titik jangkar.
class ArLabel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool busy;
  final bool warning;

  const ArLabel({
    super.key,
    required this.title,
    this.subtitle,
    this.busy = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = warning ? AppColors.amber : AppColors.forest;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(width: 2, height: 22, color: Colors.white),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}
