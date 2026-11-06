import 'package:flutter/material.dart' hide Stepper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/tasks_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_sheet_base.dart';
import '../widgets/stepper.dart';

/// 新建任务弹层。
class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _name = TextEditingController();
  int _estimate = 3;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      title: '新建任务',
      child: Column(
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '任务名称',
              hintStyle: AppTextStyles.caption,
              filled: true,
              fillColor: AppColors.surfaceHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusSmall),
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
                value: _estimate,
                min: 1,
                max: 20,
                onChanged: (v) => setState(() => _estimate = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '创建',
              onPressed: () {
                final n = _name.text.trim();
                if (n.isEmpty) return;
                ref.read(tasksProvider.notifier).add(n, _estimate);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
