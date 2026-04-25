import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProductIllustration extends StatelessWidget {
  final String iconType;
  final int bgColor;
  final double size;

  const ProductIllustration({
    super.key,
    required this.iconType,
    required this.bgColor,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size,
      color: Color(bgColor),
      child: CustomPaint(
        painter: _getPainter(iconType),
        child: const SizedBox.expand(),
      ),
    );
  }

  CustomPainter _getPainter(String type) {
    switch (type) {
      case 'bottle':
        return _BottlePainter();
      case 'vase':
        return _VasePainter();
      case 'wood':
        return _WoodPainter();
      case 'chair':
        return _ChairPainter();
      case 'bag':
        return _BagPainter();
      case 'pillow':
        return _PillowPainter();
      case 'shelf':
        return _ShelfPainter();
      case 'mirror':
        return _MirrorPainter();
      default:
        return _BottlePainter();
    }
  }
}

// ── Botol Kaca ──────────────────────────────────────────────────────────────
class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final darkPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);

    // Badan botol
    final bodyPath = Path()
      ..moveTo(cx - 18, cy - 10)
      ..quadraticBezierTo(cx - 26, cy + 10, cx - 22, cy + 30)
      ..lineTo(cx + 22, cy + 30)
      ..quadraticBezierTo(cx + 26, cy + 10, cx + 18, cy - 10)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // Leher botol
    canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 28, 16, 20), paint);

    // Mulut botol
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy - 32, 20, 6), paint);

    // Kilap
    canvas.drawRect(Rect.fromLTWH(cx - 16, cy, 5, 18), darkPaint);

    // Lampu LED di dalam
    final glowPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy + 10), 8, glowPaint);
    canvas.drawCircle(
        Offset(cx, cy + 10), 4, Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Vas Kaca ─────────────────────────────────────────────────────────────────
class _VasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final accentPaint = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.6);

    // Badan vas (lebih lebar di tengah)
    final vasePath = Path()
      ..moveTo(cx - 10, cy - 28)
      ..quadraticBezierTo(cx - 30, cy - 10, cx - 28, cy + 20)
      ..lineTo(cx + 28, cy + 20)
      ..quadraticBezierTo(cx + 30, cy - 10, cx + 10, cy - 28)
      ..close();
    canvas.drawPath(vasePath, paint);

    // Mulut vas
    canvas.drawRect(Rect.fromLTWH(cx - 14, cy - 32, 28, 6), paint);

    // Dekorasi garis
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - 20 + i * 2, cy - 10 + i * 8),
        Offset(cx + 20 - i * 2, cy - 10 + i * 8),
        accentPaint..strokeWidth = 1.5,
      );
    }

    // Bunga di dalam
    final flowerPaint = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(cx, cy - 36), 5, flowerPaint);
    canvas.drawCircle(Offset(cx - 8, cy - 40), 4, flowerPaint);
    canvas.drawCircle(Offset(cx + 8, cy - 40), 4, flowerPaint);
    canvas.drawLine(Offset(cx, cy - 28), Offset(cx, cy - 50),
        Paint()..color = Colors.green.withValues(alpha: 0.8)..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Kayu / Pot ───────────────────────────────────────────────────────────────
class _WoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final woodPaint = Paint()..color = Colors.brown.shade200;
    final darkWood = Paint()..color = Colors.brown.shade400;
    final soilPaint = Paint()..color = const Color(0xFF5D4037);
    final plantPaint = Paint()..color = Colors.green.shade400;

    // Pot
    final potPath = Path()
      ..moveTo(cx - 22, cy - 5)
      ..lineTo(cx - 18, cy + 28)
      ..lineTo(cx + 18, cy + 28)
      ..lineTo(cx + 22, cy - 5)
      ..close();
    canvas.drawPath(potPath, woodPaint);

    // Serat kayu
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 18 + i * 4, cy - 2),
        Offset(cx - 15 + i * 4, cy + 25),
        darkWood..strokeWidth = 1,
      );
    }

    // Bibir pot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 24, cy - 10, 48, 8), const Radius.circular(4)),
      woodPaint,
    );

    // Tanah
    canvas.drawOval(
        Rect.fromLTWH(cx - 20, cy - 14, 40, 12), soilPaint);

    // Tanaman
    final stemPaint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(cx, cy - 14), Offset(cx, cy - 40), stemPaint);
    canvas.drawLine(Offset(cx, cy - 30), Offset(cx - 14, cy - 38), stemPaint);
    canvas.drawLine(Offset(cx, cy - 26), Offset(cx + 14, cy - 34), stemPaint);
    canvas.drawCircle(Offset(cx, cy - 42), 8, plantPaint);
    canvas.drawCircle(Offset(cx - 16, cy - 40), 6, plantPaint);
    canvas.drawCircle(Offset(cx + 16, cy - 36), 6, plantPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Kursi Kayu ───────────────────────────────────────────────────────────────
class _ChairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final seatPaint = Paint()..color = Colors.brown.shade300;

    // Sandaran
    canvas.drawLine(Offset(cx - 22, cy - 30), Offset(cx - 22, cy + 5), paint);
    canvas.drawLine(Offset(cx + 22, cy - 30), Offset(cx + 22, cy + 5), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 24, cy - 32, 48, 10), const Radius.circular(4)),
      seatPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 24, cy - 20, 48, 6), const Radius.circular(3)),
      seatPaint,
    );

    // Dudukan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 26, cy + 2, 52, 10), const Radius.circular(4)),
      seatPaint,
    );

    // Kaki
    canvas.drawLine(Offset(cx - 20, cy + 12), Offset(cx - 22, cy + 34), paint);
    canvas.drawLine(Offset(cx + 20, cy + 12), Offset(cx + 22, cy + 34), paint);
    // Penyangga
    canvas.drawLine(Offset(cx - 20, cy + 24), Offset(cx + 20, cy + 24),
        paint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Tas Anyam ────────────────────────────────────────────────────────────────
class _BagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bagPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final linePaint = Paint()
      ..color = Colors.purple.shade200
      ..strokeWidth = 1.5;

    // Badan tas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 26, cy - 16, 52, 44), const Radius.circular(8)),
      bagPaint,
    );

    // Motif anyaman horizontal
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(cx - 26, cy - 8 + i * 8),
        Offset(cx + 26, cy - 8 + i * 8),
        linePaint,
      );
    }
    // Motif anyaman vertikal
    for (int i = 0; i < 7; i++) {
      canvas.drawLine(
        Offset(cx - 22 + i * 8, cy - 16),
        Offset(cx - 22 + i * 8, cy + 28),
        linePaint,
      );
    }

    // Handle tas
    final handlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromLTWH(cx - 16, cy - 36, 32, 24),
      math.pi,
      math.pi,
      false,
      handlePaint,
    );

    // Label recycle
    final labelPaint = Paint()..color = Colors.green.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(cx, cy + 10), 10, labelPaint);
    canvas.drawCircle(Offset(cx, cy + 10), 10,
        Paint()..color = Colors.white.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Bantal ───────────────────────────────────────────────────────────────────
class _PillowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bantal utama
    final pillowPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 30, cy - 20, 60, 40), const Radius.circular(12)),
      pillowPaint,
    );

    // Motif patchwork
    final colors = [
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.blue.shade200,
      Colors.green.shade200,
    ];
    final patches = [
      Rect.fromLTWH(cx - 28, cy - 18, 26, 18),
      Rect.fromLTWH(cx + 2, cy - 18, 26, 18),
      Rect.fromLTWH(cx - 28, cy + 2, 26, 16),
      Rect.fromLTWH(cx + 2, cy + 2, 26, 16),
    ];
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(patches[i], const Radius.circular(4)),
        Paint()..color = colors[i],
      );
    }

    // Jahitan
    final stitchPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 28, cy - 18, 26, 18), const Radius.circular(4)),
      stitchPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 2, cy - 18, 26, 18), const Radius.circular(4)),
      stitchPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Rak PVC ──────────────────────────────────────────────────────────────────
class _ShelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final pipePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final shelfPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);

    // Tiang vertikal kiri & kanan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 30, cy - 32, 8, 64), const Radius.circular(4)),
      pipePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 22, cy - 32, 8, 64), const Radius.circular(4)),
      pipePaint,
    );

    // Rak horizontal (3 tingkat)
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 30, cy - 28 + i * 22, 60, 6),
            const Radius.circular(3)),
        shelfPaint,
      );
    }

    // Buku kecil di rak
    final bookColors = [Colors.red, Colors.blue, Colors.orange, Colors.pink];
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 22 + i * 11, cy - 22, 8, 16),
            const Radius.circular(2)),
        Paint()..color = bookColors[i].withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Cermin ───────────────────────────────────────────────────────────────────
class _MirrorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bingkai kayu (tidak beraturan = driftwood)
    final framePaint = Paint()..color = Colors.brown.shade300;
    final path = Path();
    final points = [
      Offset(cx - 28, cy - 34),
      Offset(cx + 30, cy - 32),
      Offset(cx + 32, cy + 30),
      Offset(cx - 26, cy + 32),
    ];
    path.moveTo(points[0].dx, points[0].dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, framePaint);

    // Cermin (dalam)
    canvas.drawOval(
      Rect.fromLTWH(cx - 20, cy - 26, 40, 52),
      Paint()..color = Colors.lightBlue.shade100.withValues(alpha: 0.7),
    );

    // Kilap cermin
    canvas.drawLine(
      Offset(cx - 8, cy - 20),
      Offset(cx - 14, cy - 8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Serat kayu di bingkai
    final grainPaint = Paint()
      ..color = Colors.brown.shade500
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(cx - 26, cy - 20), Offset(cx - 22, cy + 10), grainPaint);
    canvas.drawLine(
        Offset(cx + 28, cy - 15), Offset(cx + 24, cy + 15), grainPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
