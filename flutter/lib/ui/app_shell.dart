import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/stats_screen.dart';
import 'widgets/floating_tab_bar.dart';

/// 全局选中 Tab。
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// 应用主壳：三视图 IndexedStack + 悬浮 Tab Bar。设置由主页齿轮进入。
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: const [
                    HomeScreen(),
                    TasksScreen(),
                    StatsScreen(),
                  ],
                ),
              ),
              const Center(child: FloatingTabBar()),
            ],
          ),
        ),
      ),
    );
  }
}
