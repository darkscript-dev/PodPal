import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

//this file is 90% ai generated

class AnimatedPlant extends StatefulWidget {
  final double health;

  const AnimatedPlant({Key? key, this.health = 1.0}) : super(key: key);

  @override
  _AnimatedPlantState createState() => _AnimatedPlantState();
}

class _AnimatedPlantState extends State<AnimatedPlant>
    with TickerProviderStateMixin { // Using TickerProviderStateMixin for two controllers
  late AnimationController _swayController;
  late AnimationController _blinkController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _blinkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && Random().nextDouble() > 0.4) {
        _blinkController.forward().then((_) => _blinkController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _swayController.dispose();
    _blinkController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return AnimatedBuilder(
            animation: Listenable.merge([_swayController, _blinkController]),
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: PlantPainter(
                  sway: _swayController.value,
                  blink: _blinkController.value,
                  health: widget.health,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlantPainter extends CustomPainter {
  final double sway;
  final double blink;
  final double health;

  PlantPainter({required this.sway, required this.blink, required this.health});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 1 || size.height < 1) return;

    final center = Offset(size.width / 2, size.height / 2 + 60);
    final plantHeight = size.height * 0.55;

    // --- Paints ---
    final outlinePaint = Paint()
      ..color = const Color(0xFF1A211B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final potPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC47C5A), Color(0xFFA15A3A)],
      ).createShader(Rect.fromCircle(center: center, radius: 100));

    final soilPaint = Paint()..color = const Color(0xFF4A3B31);
    final healthyStemColor = const Color(0xFF4B5A42);
    final unhealthyStemColor = const Color(0xFF6B644B);
    final currentStemColor = Color.lerp(unhealthyStemColor, healthyStemColor, health)!;
    final stemPaint = Paint()..color = currentStemColor..strokeWidth=5..strokeCap=StrokeCap.round;

    final swayAngle = (sin(sway * 2 * pi)) * 0.08;

    // --- Draw The "Terracotta Squircle" Pot ---
    final potWidth = size.width * 0.5;
    final potHeight = potWidth * 0.9;
    final potRect = Rect.fromCenter(center: center, width: potWidth, height: potHeight);
    final potSquircle = RRect.fromRectAndRadius(potRect, const Radius.circular(35));

    canvas.drawRRect(potSquircle, potPaint);
    canvas.drawRRect(potSquircle, outlinePaint);

    // Rim
    final potRimRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -potHeight/2), width: potWidth, height: 20),
        const Radius.circular(10)
    );
    canvas.drawRRect(potRimRect, potPaint);
    canvas.drawRRect(potRimRect, outlinePaint);

    // Soil
    canvas.drawRect(
        Rect.fromCenter(center: center.translate(0, -potHeight/2), width: potWidth - 20, height: 10),
        soilPaint
    );

    // --- Draw Face on Pot ---
    _drawFace(canvas, center, potHeight, outlinePaint, health, blink);

    // --- Animate the Plant ---
    final stemBase = Offset(center.dx, center.dy - potHeight/2);
    canvas.save();
    canvas.translate(stemBase.dx, stemBase.dy);
    canvas.rotate(swayAngle);
    canvas.translate(-stemBase.dx, -stemBase.dy);

    final stemPath = Path()..moveTo(stemBase.dx, stemBase.dy);
    final healthyControlPoint = Offset(stemBase.dx + plantHeight * 0.2, stemBase.dy - plantHeight * 0.5);
    final unhealthyControlPoint = Offset(stemBase.dx + plantHeight * 0.1, stemBase.dy - plantHeight * 0.2);
    final controlPoint = Offset.lerp(unhealthyControlPoint, healthyControlPoint, health)!;
    final endPoint = Offset(stemBase.dx - plantHeight * 0.1, stemBase.dy - plantHeight);
    stemPath.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    canvas.drawPath(stemPath, stemPaint..style=PaintingStyle.stroke);

    final pathMetrics = stemPath.computeMetrics().first;
    final totalLength = pathMetrics.length;
    _drawLeaf(canvas, pathMetrics.getTangentForOffset(totalLength * 0.3)!, -1.2, 1.0, swayAngle, outlinePaint, health);
    _drawLeaf(canvas, pathMetrics.getTangentForOffset(totalLength * 0.6)!, 1.2, 0.9, swayAngle, outlinePaint, health);
    _drawLeaf(canvas, pathMetrics.getTangentForOffset(totalLength * 0.95)!, 0, 0.8, swayAngle, outlinePaint, health);

    canvas.restore();
  }

  void _drawFace(Canvas canvas, Offset potCenter, double potHeight, Paint outline, double health, double blink) {
    final eyeY = potCenter.dy - potHeight * 0.1;
    final eyeHeight = 18.0 * (1 - blink);

    // Eyes
    final eyePaint = Paint()..color = outline.color;
    final eyeHighlightPaint = Paint()..color = Colors.white.withOpacity(0.9);

    final leftEyeRect = Rect.fromCenter(center: Offset(potCenter.dx - 25, eyeY), width: 14, height: eyeHeight);
    canvas.drawOval(leftEyeRect, eyePaint);
    if(eyeHeight > 2) canvas.drawCircle(leftEyeRect.center.translate(3, -3), 2.5, eyeHighlightPaint);

    final rightEyeRect = Rect.fromCenter(center: Offset(potCenter.dx + 25, eyeY), width: 14, height: eyeHeight);
    canvas.drawOval(rightEyeRect, eyePaint);
    if(eyeHeight > 2) canvas.drawCircle(rightEyeRect.center.translate(3, -3), 2.5, eyeHighlightPaint);

    // Mouth changes based on health
    final mouthPath = Path();
    final mouthY = eyeY + 25;
    if (health > 0.5) { // Happy
      mouthPath.moveTo(potCenter.dx - 15, mouthY);
      mouthPath.quadraticBezierTo(potCenter.dx, mouthY + 12, potCenter.dx + 15, mouthY);
    } else { // Sad
      mouthPath.moveTo(potCenter.dx - 15, mouthY + 5);
      mouthPath.quadraticBezierTo(potCenter.dx, mouthY - 5, potCenter.dx + 15, mouthY + 5);
    }
    canvas.drawPath(mouthPath, outline..style=PaintingStyle.stroke..strokeWidth=3);
  }

  void _drawLeaf(Canvas canvas, Tangent tangent, double angleOffset, double scale, double swayAngle, Paint outline, double health) {
    canvas.save();
    canvas.translate(tangent.position.dx, tangent.position.dy);
    canvas.rotate(tangent.angle + angleOffset + swayAngle * 0.5);
    canvas.scale(scale);

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(25, -20, 10, -50)
      ..quadraticBezierTo(-5, -35, 0, 0)
      ..close();

    final healthyTop = const Color(0xFF5A8263);
    final healthyBottom = const Color(0xFF2E462F);
    final unhealthyTop = const Color(0xFFB3A54D);
    final unhealthyBottom = const Color(0xFF7A713C);
    final currentTop = Color.lerp(unhealthyTop, healthyTop, health)!;
    final currentBottom = Color.lerp(unhealthyBottom, healthyBottom, health)!;

    final leafPaint = Paint()
      ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.2),
          colors: [currentTop, currentBottom]
      ).createShader(path.getBounds());

    canvas.drawPath(path, leafPaint);
    canvas.drawPath(path, outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PlantPainter oldDelegate) {
    return oldDelegate.sway != sway ||
        oldDelegate.health != health ||
        oldDelegate.blink != blink;
  }
}