import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 极简分段控件：发丝胶囊容器 + 选中项高亮面。
/// 主页（专注/短休/长休）与统计页（日/周/月）共用。
class AppSegmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const AppSegmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: i == index ? AppColors.surfaceHigh : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  labels[i],
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 13,
                    color: i == index
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
