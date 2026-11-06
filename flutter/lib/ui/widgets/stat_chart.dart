import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/stats_provider.dart';

/// 极简柱状图：单色（薄荷绿）圆角柱 + 发丝基线 + 弱化标签。
/// 去掉渐变与发光，只保留数据本身。
class StatChart extends StatelessWidget {
  final List<ChartPoint> points;
  final double height;

  const StatChart({super.key, required this.points, this.height = 160});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无数据', style: AppTextStyles.caption),
        ),
      );
    }
    // 全为 0 时没必要时画出空坐标轴，直接给一句占位。
    if (points.every((p) => p.value <= 0)) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '暂无数据',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(points: points),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ChartPoint> points;

  _ChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final top = maxV == 0 ? 1 : maxV.toDouble();
    const padBottom = 22.0;
    const padTop = 8.0;
    final usableH = size.height - padBottom - padTop;
    final slot = size.width / points.length;
    final barW = slot * 0.42;

    // 基线
    canvas.drawLine(
      Offset(0, size.height - padBottom),
      Offset(size.width, size.height - padBottom),
      Paint()
        ..color = AppColors.hairline
        ..strokeWidth = 1,
    );

    final barPaint = Paint()..color = AppColors.accent;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = slot * i + (slot - barW) / 2;

      if (p.value <= 0) {
        // 空数据：画 2px 极弱短柱，保持节奏感
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                x, size.height - padBottom - 2, barW, 2),
            const Radius.circular(1),
          ),
          Paint()..color = AppColors.hairline,
        );
      } else {
        final h = (p.value / top) * usableH;
        final y = size.height - padBottom - h;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barW, h),
            Radius.circular(barW / 2),
          ),
          barPaint,
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: p.label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(slot * i + (slot - tp.width) / 2, size.height - padBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.points != points;
}
