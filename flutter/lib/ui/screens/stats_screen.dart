import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/stats_provider.dart';
import '../widgets/app_segmented.dart';
import '../widgets/metric_item.dart';
import '../widgets/stat_chart.dart';

/// 统计页：专注分 + 趋势图 + 三个核心指标。
/// 极简：去掉成就宝石与装饰，只保留数据本身。
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _range = 0; // 0=日 1=周 2=月

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    final points = _range == 0
        ? stats.dayPoints
        : _range == 1
            ? stats.weekPoints
            : stats.monthPoints;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 24,
        title: Text('统计', style: AppTextStyles.h1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 专注分
            Center(
              child: Column(
                children: [
                  Text(
                    '${stats.score}',
                    style: AppTextStyles.display.copyWith(fontSize: 56),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '专注分',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 范围切换
            Center(
              child: AppSegmented(
                labels: const ['日', '周', '月'],
                index: _range,
                onChanged: (i) => setState(() => _range = i),
              ),
            ),
            const SizedBox(height: 20),

            StatChart(points: points),
            const SizedBox(height: 28),

            // 核心指标
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.hairline),
                  bottom: BorderSide(color: AppColors.hairline),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MetricItem(
                      value: '${stats.todayPomodoros}',
                      label: '今日番茄',
                    ),
                  ),
                  const _VLine(),
                  Expanded(
                    child: MetricItem(
                      value: '${stats.todayFocusMinutes}',
                      label: '专注分钟',
                    ),
                  ),
                  const _VLine(),
                  Expanded(
                    child: MetricItem(
                      value: '${stats.streak}',
                      label: '连续天数',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.hairline);
  }
}
