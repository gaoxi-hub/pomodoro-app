import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 分段进度条。极简：细、无发光、无渐变。
class PomodoroBar extends StatelessWidget {
  final double progress; // 0..1
  final int segments;
  final double height;

  const PomodoroBar({
    super.key,
    required this.progress,
    required this.segments,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final count = segments.clamp(1, 16);
    final filled = (progress * count).round();
    return Row(
      children: [
        for (int i = 0; i < count; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < count - 1 ? 3 : 0),
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                color: i < filled ? AppColors.accent : AppColors.hairline,
              ),
            ),
          ),
      ],
    );
  }
}
