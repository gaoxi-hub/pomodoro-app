import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 极简按钮。
/// - primary：薄荷绿实心 + 黑字（唯一的强操作）；
/// - secondary：透明底 + 发丝描边。
/// 高度固定 48，宽度由外层约束决定（放进 SizedBox 即可拉伸）。
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Colors.black : AppColors.textPrimary;

    return Material(
      color: primary ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(AppColors.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        onTap: onPressed,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.radiusPill),
            border: primary ? null : Border.all(color: AppColors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
