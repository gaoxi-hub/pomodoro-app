import 'dart:convert';
import 'package:flutter/material.dart' hide Stepper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/models/goal.dart';
import '../../core/models/settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/achievements_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tasks_provider.dart';
import '../sheets/noise_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_switch.dart';
import '../widgets/bottom_sheet_base.dart';
import '../widgets/stepper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsProvider).valueOrNull ?? Settings.defaults();
    final goal = ref.watch(goalProvider).valueOrNull ?? const Goal();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('设置', style: AppTextStyles.h1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('计时时长（分钟）'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Column(
                children: _divided([
                  _Row('专注', settings.workMin, 1, 90,
                      (v) => _patch(ref, workMin: v)),
                  _Row('短休', settings.shortMin, 1, 30,
                      (v) => _patch(ref, shortMin: v)),
                  _Row('长休', settings.longMin, 1, 60,
                      (v) => _patch(ref, longMin: v)),
                  _Row('长休间隔（轮）', settings.longBreakInterval, 2, 8,
                      (v) => _patch(ref, longBreakInterval: v)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('行为'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Column(
                children: _divided([
                  _SwitchRow('自动开始下一轮', settings.autoStartNext,
                      (v) => _patch(ref, autoStartNext: v)),
                  _SwitchRow('完成提示音', settings.soundOn,
                      (v) => _patch(ref, soundOn: v)),
                  _SwitchRow('完成庆祝动效', settings.celebrate,
                      (v) => _patch(ref, celebrate: v)),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('每日目标'),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text('每日番茄目标', style: AppTextStyles.body),
                  const Spacer(),
                  Stepper(
                    value: goal.dailyPomodoros,
                    min: 1,
                    max: 30,
                    onChanged: (v) =>
                        ref.read(goalProvider.notifier).setDaily(v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('环境音'),
            AppCard(
              onTap: () => showAppSheet(context, const NoiseSheet()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq_rounded,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Text('白噪音', style: AppTextStyles.body),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('数据'),
            AppCard(
              onTap: () => _export(context, ref),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.upload_outlined,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Text('导出本地数据', style: AppTextStyles.body),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _patch(
    WidgetRef ref, {
    int? workMin,
    int? shortMin,
    int? longMin,
    int? longBreakInterval,
    bool? autoStartNext,
    bool? soundOn,
    bool? celebrate,
  }) {
    ref.read(settingsProvider.notifier).patch(
          workMin: workMin,
          shortMin: shortMin,
          longMin: longMin,
          longBreakInterval: longBreakInterval,
          autoStartNext: autoStartNext,
          soundOn: soundOn,
          celebrate: celebrate,
        );
  }

  void _export(BuildContext context, WidgetRef ref) {
    final tasks = ref.read(tasksProvider).valueOrNull?.tasks ?? [];
    final sessions = ref.read(sessionProvider).valueOrNull ?? [];
    final settings =
        ref.read(settingsProvider).valueOrNull ?? Settings.defaults();
    final goal = ref.read(goalProvider).valueOrNull ?? const Goal();
    final ach =
        ref.read(achievementsProvider).valueOrNull?.map((a) => a.id).toList() ??
            [];

    final data = {
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'settings': settings.toJson(),
      'goal': goal.toJson(),
      'achievements': ach,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDeep,
        title: Text('导出数据', style: AppTextStyles.h2),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: json)),
            child: Text(
              '复制',
              style: AppTextStyles.body.copyWith(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '关闭',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 在行之间插入发丝分隔线。
List<Widget> _divided(List<Widget> rows) {
  final out = <Widget>[];
  for (var i = 0; i < rows.length; i++) {
    out.add(rows[i]);
    if (i != rows.length - 1) {
      out.add(const Divider(height: 1, color: AppColors.hairline));
    }
  }
  return out;
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(text, style: AppTextStyles.overline),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Row(this.label, this.value, this.min, this.max, this.onChanged);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.body),
            const Spacer(),
            Stepper(value: value, min: min, max: max, onChanged: onChanged),
          ],
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.body),
            const Spacer(),
            AppSwitch(value: value, onChanged: onChanged),
          ],
        ),
      );
}
