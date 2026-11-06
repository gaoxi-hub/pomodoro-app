import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 极简指标：数值 + 标签。无边框、无图标、无背景。
class MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const MetricItem({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            fontSize: 22,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
