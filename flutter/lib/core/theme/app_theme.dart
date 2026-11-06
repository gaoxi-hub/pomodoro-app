import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 全局唯一主题：极简暗色。不提供浅色。
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          onPrimary: Colors.black,
          secondary: AppColors.accentSecondary,
          error: AppColors.warn,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.display,
          headlineLarge: AppTextStyles.h1,
          titleLarge: AppTextStyles.h2,
          bodyMedium: AppTextStyles.body,
          labelSmall: AppTextStyles.caption,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        dividerColor: AppColors.hairline,
        dividerTheme: const DividerThemeData(
          color: AppColors.hairline,
          thickness: 1,
          space: 1,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
        ),
      );
}
