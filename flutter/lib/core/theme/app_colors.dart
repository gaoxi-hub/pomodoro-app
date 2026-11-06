import 'package:flutter/material.dart';

/// 设计令牌 —— 个人极简风（极简暗色）。
///
/// 原则：
/// - 近黑底 + 纯色面，只靠 1px 发丝描边区分层次，不用毛玻璃/阴影；
/// - 薄荷绿只用于「进行中 / 主操作 / 选中」；
/// - 文字用略带灰度的白，降低刺眼感。
class AppColors {
  AppColors._();

  // ---- 背景 ----
  /// 背景-主：近黑
  static const Color bgPrimary = Color(0xFF0B0C0B);

  /// 背景-深：弹层 / 强调面
  static const Color bgDeep = Color(0xFF111412);

  // ---- 面 ----
  /// 卡片面
  static const Color surface = Color(0xFF151816);

  /// 高一层：选中态 / 悬浮元素
  static const Color surfaceHigh = Color(0xFF1B1F1C);

  /// 发丝描边（约 7% 白）
  static const Color hairline = Color(0x12FFFFFF);

  // ---- 强调 ----
  /// 强调-主：薄荷绿
  static const Color accent = Color(0xFF7FFFD4);

  /// 强调-辅：休息态 / 次级高亮
  static const Color accentSecondary = Color(0xFFA6E6CB);

  /// 警示
  static const Color warn = Color(0xFFFF7A8A);

  /// 能量（连续打卡等）
  static const Color energy = Color(0xFFFFB26B);

  // ---- 文字 ----
  /// 文字-主：柔和白
  static const Color textPrimary = Color(0xFFECEFEC);

  /// 文字-次
  static const Color textSecondary = Color(0xFF98A09A);

  /// 文字-弱
  static const Color textTertiary = Color(0xFF5E655F);

  // ---- Tab / 背景 ----
  /// Tab Bar 底色（半透明纯色）
  static const Color tabBarBg = Color(0xF2131614);

  /// 背景氛围渐变（极弱，仅避免纯黑死板）
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B0C0B), Color(0xFF0F1210)],
  );

  // 圆角体系（全 App 不出现直角）
  static const double radiusCard = 18;
  static const double radiusPill = 999;
  static const double radiusSmall = 12;
}
