import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 极简底部弹层：纯色面 + 顶部发丝线 + 细拖拽手柄。
class BottomSheetBase extends StatelessWidget {
  final String title;
  final Widget child;

  const BottomSheetBase({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.radiusCard),
        ),
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// 统一弹出底部弹层。
Future<T?> showAppSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => child,
  );
}
