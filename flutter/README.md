# 番茄钟 App · Flutter 原生版

基于番茄工作法的专注计时与任务管理工具，**纯本地、无后端**，对应原 `h5/` 的 Vue3 实现，用 Flutter 重写为可上架 iOS / Android 的真原生 App。

- 视觉：暗黑沉浸 + 荧光薄荷绿（`#7FFFD4`）发光，严格对齐 `../design/DESIGN.md`
- 数据：全部存本地（`shared_preferences`，键前缀 `pomodoro:`），刷新/重装不丢
- 计时：时间戳精确计时（挂起/切后台不漂移）
- 提醒：原生**本地通知**（开始时调度定点通知，解决 WebView 不支持 Web Notifications、后台被杀也能准时提醒）
- 音频：完成提示音（合成 ding）+ 白噪音环境音

## 技术栈

| 层 | 选型 |
| --- | --- |
| 框架/语言 | Flutter 3 + Dart 3 |
| 状态 | flutter_riverpod（各域一个 Notifier，本地持久化） |
| 持久化 | shared_preferences（前缀 `pomodoro:`） |
| 计时 | 自研 `TimerService`（时间戳法） |
| 声音 | audioplayers（资产播放，无后端） |
| 通知 | flutter_local_notifications（含 timezone 精确调度） |
| 图表/环 | 手写 CustomPaint（无第三方图表库） |

## 目录结构

```
flutter/
  lib/
    core/
      theme/      # 设计令牌：app_colors / app_text_styles / app_theme
      constants/  # storage_keys（pomodoro: 前缀）/ app_constants
      models/     # Task / PomodoroSession / Settings / Goal / Achievement / NoiseSound
      utils/      # time_utils / id_utils
    data/
      storage/        # LocalStorage 封装
      repositories/   # task/session/settings/goal/achievement 仓储
    services/     # timer_service / audio_service / notification_service
    providers/    # tasks/settings/goal/session/timer/stats/achievements
    ui/
      widgets/    # GlassCard / GlowButton / PillMetric / TimerRing / FloatingTabBar
                  # TaskCard / PomodoroBar / StatChart / GemCard / AppSwitch / Stepper / BottomSheetBase
      screens/    # Home / Tasks / Stats / Settings
      sheets/     # AddTask / PickTask / Noise
  assets/audio/   # ding.wav（提示音）+ 14 个白噪音素材（来自原 H5）
```

## 与原 H5 的对应关系

- 数据模型字段、键前缀 `pomodoro:` 与原 `h5/src/types/index.ts`、`useStorage` **完全一致**（Task / PomodoroSession / Settings / Goal / Achievements）。
- `useNotify`（Web Notifications）→ `notification_service`（原生本地通知，开始时 `zonedSchedule` 定点触发）。
- `useTimer`（时间戳法）→ `timer_service`（同样基于目标结束时间戳）。
- `useAudio`（Web Audio 合成）→ `audio_service`（ding.wav + 白噪音资产）。
- 设计令牌（色板/圆角/发光/字体）逐条迁移到 `core/theme`，UI 视觉 1:1 还原 DESIGN.md。

## 环境准备

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started)（Apple Silicon 选 `arm64` 版），确保 `flutter doctor` 无红。
2. iOS 需 Xcode（Mac 已具备）；Android 需 Android Studio + SDK。

## 初始化原生工程并运行

当前 `flutter/` 已包含完整 Dart 工程，但**尚未生成 `android/` 与 `ios/` 原生壳**（需 Flutter SDK）。安装好 SDK 后：

```bash
cd flutter
flutter create --platforms=ios,android .   # 生成原生工程（不覆盖 lib/）
flutter pub get
flutter run                                 # 连真机/模拟器运行
flutter build ios                           # 出 iOS 包
flutter build appbundle                     # 出 Android AAB
```

## 权限 / 原生配置

**Android**（`android/app/src/main/AndroidManifest.xml`，`flutter create` 后补）：
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```
并在 `<application>` 内确保通知渠道（代码已用 `AppConstants.notificationChannelId` 声明）。

**iOS**（`ios/Runner/Info.plist`）：开启 Xcode 的 **Push Notifications** 能力；通知权限由 `flutter_local_notifications` 在首次启动时请求，无需额外 plist 键（定点通知无需 `UIBackgroundModes`）。

## 双商店上架清单

- [ ] `flutter build ios` / `flutter build appbundle` 通过
- [ ] 应用图标：用 `flutter_launcher_icons` 生成各分辨率图标（替换默认 Flutter 图标）
- [ ] 启动屏（可选 splash，可加 `flutter_native_splash`）
- [ ] Android：Play Console 上传 AAB + 签名密钥 + 隐私政策链接 + 截图
- [ ] iOS：Apple Developer $99/年账号；Xcode 配置 Bundle ID / 签名 / 证书；App Store Connect 提交 + 截图 + 隐私营养标签
- [ ] 隐私：应用纯本地、不收集数据，商店声明"不收集用户数据"

## 已知简化点

- 白噪音在 Flutter 端按"首个开启音轨"单轨循环播放（原 H5 支持多层叠加，移动端混音成本较高，故简化）。
- 后台计时依赖"开始时调度的本地通知"而非后台常驻进程，更省电、更符合商店规范。
- 成就规则（S12）、每日目标与导出（S13）均已实现；导出以弹窗 JSON + 复制到剪贴板呈现。
