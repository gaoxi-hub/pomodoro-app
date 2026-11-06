import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 极简卡片：纯色面 + 1px 发丝描边。无模糊、无阴影、无渐变。
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? fill;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.onTap,
    this.fill,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppColors.radiusCard;
    final card = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.hairline),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
