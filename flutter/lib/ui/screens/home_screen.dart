import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/time_utils.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/timer_service.dart';
import '../sheets/pick_task_sheet.dart';
import '../sheets/noise_sheet.dart';
import '../screens/settings_screen.dart';
import '../widgets/bottom_sheet_base.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_segmented.dart';
import '../widgets/timer_ring.dart';

/// 主页：极简焦点页。
/// 只保留「模式 → 计时 → 操作 → 当前任务」，不再堆统计指标。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerServiceProvider);
    final tasksState = ref.watch(tasksProvider).valueOrNull;
    final current = tasksState?.current;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final noiseOn = settings?.noise.activeSound != null;

    final running = timer.isRunning;
    final label = running ? '暂停' : (timer.isPaused ? '继续' : '开始');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('番茄钟', style: AppTextStyles.h1),
            const SizedBox(height: 2),
            Text(
              formatTodayCN(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '白噪音',
            icon: Icon(
              Icons.graphic_eq_rounded,
              size: 22,
              color: noiseOn ? AppColors.accent : AppColors.textSecondary,
            ),
            onPressed: () => showAppSheet(context, const NoiseSheet()),
          ),
          IconButton(
            tooltip: '设置',
            icon: const Icon(
              Icons.settings_outlined,
              size: 22,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _ModeSelector(
                      mode: timer.mode,
                      onSelect: (m) =>
                          ref.read(timerControllerProvider).selectMode(m),
                    ),
                    const SizedBox(height: 36),
                    TimerRing(
                      progress: timer.progress,
                      timeText: formatMMSS(timer.remainingSec),
                      mode: timer.mode,
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 104,
                          child: AppButton(
                            label: '重置',
                            primary: false,
                            onPressed: () =>
                                ref.read(timerControllerProvider).reset(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 152,
                          child: AppButton(
                            label: label,
                            onPressed: () {
                              final c = ref.read(timerControllerProvider);
                              if (running) {
                                c.pause();
                              } else {
                                c.start();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: _CurrentTaskCard(
                    current: current,
                    onTap: () =>
                        showAppSheet(context, const PickTaskSheet()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 模式切换（专注 / 短休 / 长休）。
class _ModeSelector extends StatelessWidget {
  final TimerMode mode;
  final ValueChanged<TimerMode> onSelect;

  const _ModeSelector({required this.mode, required this.onSelect});

  static const _order = [TimerMode.work, TimerMode.short, TimerMode.long];
  static const _labels = ['专注', '短休', '长休'];

  @override
  Widget build(BuildContext context) {
    return AppSegmented(
      labels: _labels,
      index: _order.indexOf(mode),
      onChanged: (i) => onSelect(_order[i]),
    );
  }
}

/// 当前任务：一行信息 + 进入选择。
class _CurrentTaskCard extends StatelessWidget {
  final Task? current;
  final VoidCallback onTap;

  const _CurrentTaskCard({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final has = current != null;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前任务',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  has ? current!.name : '未选择任务',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 16,
                    color: has ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (has)
            Text(
              '${current!.done}/${current!.estimate}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
