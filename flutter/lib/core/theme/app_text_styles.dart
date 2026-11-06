import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 字体与排版 —— 个人极简风。
///
/// 字号收敛、字重变轻、行距放松；数字统一 tabular-nums 避免倒计时抖动。
/// 字体交给平台默认（iOS = SF / PingFang，Android = Roboto / Noto），
/// 比硬编码 `-apple-system` 在 Android 上更可靠。
class AppTextStyles {
  AppTextStyles._();

  /// Display：大数字（倒计时 / 专注分）
  static const TextStyle display = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.0,
    letterSpacing: -1.2,
  );

  /// H1：页面标题
  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// H2：卡片 / 弹层标题
  static const TextStyle h2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
  );

  /// Body：正文
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Caption：辅助标签
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  /// Overline：极小的分区标题
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 1.2,
  );
}
