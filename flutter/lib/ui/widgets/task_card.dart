import 'package:flutter/material.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';
import 'pomodoro_bar.dart';

/// 任务卡片（极简）：名称 + 进度 + 细分段进度条。
/// 编辑/删除收进右上角溢出菜单，日常浏览不放常驻按钮。
class TaskCard extends StatelessWidget {
  final Task task;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.selected = false,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasMenu = onEdit != null || onDelete != null;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(16, 14, hasMenu ? 4 : 16, 14),
      borderColor: selected ? AppColors.accent.withOpacity(0.35) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (selected) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        task.name,
                        style: AppTextStyles.h2.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${task.done}/${task.estimate} 番茄',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                PomodoroBar(progress: task.progress, segments: task.estimate),
              ],
            ),
          ),
          if (hasMenu)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 20,
              color: AppColors.surfaceHigh,
              icon: const Icon(Icons.more_horiz, color: AppColors.textTertiary),
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('编辑', style: AppTextStyles.body),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      '删除',
                      style: AppTextStyles.body.copyWith(color: AppColors.warn),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
