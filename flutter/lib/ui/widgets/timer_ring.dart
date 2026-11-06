import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/timer_service.dart';

/// 中央计时环 —— 细弧进度 + 大号倒计时。
/// 极简处理：数字用柔和白、不加发光；只有进度弧带颜色。
class TimerRing extends StatelessWidget {
  final double progress; // 0..1
  final String timeText;
  final TimerMode mode;
  final double size;

  const TimerRing({
    super.key,
    required this.progress,
    required this.timeText,
    required this.mode,
    this.size = 268,
  });

  Color get color =>
      mode == TimerMode.work ? AppColors.accent : AppColors.accentSecondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: AppTextStyles.display.copyWith(fontSize: 58),
              ),
              const SizedBox(height: 10),
              Text(
                mode == TimerMode.work
                    ? '专注'
                    : (mode == TimerMode.short ? '短休' : '长休'),
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double stroke;

  _RingPainter({
    required this.progress,
    required this.color,
    this.stroke = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const start = -pi / 2;
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
