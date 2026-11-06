import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/tasks_provider.dart';
import '../widgets/bottom_sheet_base.dart';
import '../widgets/task_card.dart';

/// 选择当前任务弹层。
class PickTaskSheet extends ConsumerWidget {
  const PickTaskSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksProvider).valueOrNull;
    final tasks = state?.tasks ?? [];
    final currentId = state?.currentTaskId;

    return BottomSheetBase(
      title: '选择当前任务',
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final t in tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TaskCard(
                  task: t,
                  selected: t.id == currentId,
                  onTap: () {
                    ref.read(tasksProvider.notifier).setCurrent(t.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            TextButton(
              onPressed: () {
                ref.read(tasksProvider.notifier).setCurrent(null);
                Navigator.pop(context);
              },
              child: Text(
                '不使用任务',
                style: AppTextStyles.caption.copyWith(color: AppColors.warn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
