import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../app_shell.dart';

/// 悬浮胶囊 Tab Bar（3 Tab）。极简：纯色底 + 发丝描边，无模糊。
class FloatingTabBar extends ConsumerWidget {
  const FloatingTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.tabBarBg,
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _tabs.length; i++)
            _TabItem(
              icon: _tabs[i].icon,
              label: _tabs[i].label,
              active: index == i,
              onTap: () => ref.read(tabIndexProvider.notifier).state = i,
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          color: active ? AppColors.surfaceHigh : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: active ? AppColors.textPrimary : AppColors.textTertiary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _tabs = [
  _Tab(icon: Icons.timer_outlined, label: '主页'),
  _Tab(icon: Icons.checklist_rounded, label: '任务'),
  _Tab(icon: Icons.bar_chart_rounded, label: '统计'),
];

class _Tab {
  final IconData icon;
  final String label;
  const _Tab({required this.icon, required this.label});
}
