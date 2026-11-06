import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/storage_providers.dart';
import 'ui/app_shell.dart';

/// 应用根：初始化通知权限，等待本地存储就绪后进入主壳。
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final n = ref.read(notificationServiceProvider);
      await n.init();
      await n.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '番茄钟',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const Bootstrap(),
    );
  }
}

/// 等待本地存储初始化（localStorageProvider）的启动守卫。
class Bootstrap extends ConsumerWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ls = ref.watch(localStorageProvider);
    if (ls is! AsyncData) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    return const AppShell();
  }
}
