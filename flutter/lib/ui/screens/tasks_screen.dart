import 'package:flutter/material.dart' hide Stepper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/tasks_provider.dart';
import '../sheets/add_task_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_sheet_base.dart';
import '../widgets/stepper.dart';
import '../widgets/task_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksProvider).valueOrNull;
    final tasks = state?.tasks ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 24,
        title: Text('任务', style: AppTextStyles.h1),
        actions: [
          if (tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Center(
                child: Text(
                  '${tasks.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.checklist_rounded,
                    size: 40,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '还没有任务',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点右下角 + 新建一个',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = tasks[i];
                return TaskCard(
                  task: t,
                  selected: state?.currentTaskId == t.id,
                  onTap: () =>
                      ref.read(tasksProvider.notifier).setCurrent(t.id),
                  onEdit: () => _showEditSheet(context, ref, t),
                  onDelete: () =>
                      _confirmDelete(context, ref, t.id, t.name),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAppSheet(context, const AddTaskSheet()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDeep,
        title: Text('删除任务', style: AppTextStyles.h2),
        content: Text('确定删除「$name」？', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '取消',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).remove(id);
              Navigator.pop(ctx);
            },
            child: Text(
              '删除',
              style: AppTextStyles.body.copyWith(color: AppColors.warn),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Task task) {
    final nameCtl = TextEditingController(text: task.name);
    int estimate = task.estimate;
    showAppSheet(
      context,
      StatefulBuilder(
        builder: (ctx, setState) => BottomSheetBase(
          title: '编辑任务',
          child: Column(
            children: [
              TextField(
                controller: nameCtl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: '任务名称',
                  hintStyle: AppTextStyles.caption,
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppColors.radiusSmall),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text('预估番茄数', style: AppTextStyles.body),
                  const Spacer(),
                  Stepper(
                    value: estimate,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => estimate = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: '保存',
                  onPressed: () {
                    final n = nameCtl.text.trim();
                    if (n.isEmpty) return;
                    ref
                        .read(tasksProvider.notifier)
                        .updateTask(task.id, name: n, estimate: estimate);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
