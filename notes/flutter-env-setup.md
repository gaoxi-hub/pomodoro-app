# Flutter 开发环境搭建笔记

> 适用环境：Apple Silicon Mac（arm64）· macOS 26 Tahoe
> 目标工程：`pomodoro-app/flutter/`（番茄钟 App 的 Flutter 原生版）
> 目标：能跑 `flutter run` 启动项目（Android 模拟器即可；iOS 模拟器/真机需额外装 Xcode）

---

## 一、本机现状盘点（已实测）

| 工具 | 状态 | 说明 |
| --- | --- | --- |
| Homebrew | ✅ 已装 6.0.22 | 装包主力，下面会用到 |
| Xcode Command Line Tools | ✅ 已装 26.6.0 | 编译原生依赖需要，已满足 |
| Java（OpenJDK） | ✅ 已装 21 | Android 构建需要，已满足 |
| Android Studio | ✅ 已装 | 但还没配 SDK / 模拟器镜像 |
| **Flutter SDK（含 Dart）** | ❌ **未装** | 核心，必须自己装 |
| **Xcode** | ❌ **未装** | 仅影响 iOS；只跑 Android 可跳过 |
| Dart | ❌ 随 Flutter 一并装 | 不用单独装 |

**结论**：你只需要补两样核心东西 —— **Flutter SDK** 和 **Android 模拟器（含 SDK 镜像）**；想跑 iOS 再补 **Xcode**。

---

## 二、需要自己安装的清单

### 必装（跑通 Android）
1. **Flutter SDK**（自带 Dart，选 Apple Silicon 版）
2. **Android SDK + 系统镜像 + 一个 AVD 模拟器**（Android Studio 已装，只需在 GUI 里补齐）

### 仅 iOS 需要（可选）
3. **Xcode 26**（App Store，约 7GB+，体积大、下载慢，按需再装）
4. **CocoaPods**（iOS 原生依赖管理）

### 推荐（非必须）
- **fvm**：Flutter 版本管理，可锁定工程 SDK 版本，避免以后升级踩坑
- **VS Code / Android Studio 的 Flutter & Dart 插件**：写代码更顺手

---

## 三、安装步骤

### 1. 装 Flutter SDK（Apple Silicon 原生版）

1. 去官网下载 **macOS / Apple Silicon** 的 Stable 版 zip：
   https://docs.flutter.dev/get-started/install/macos
2. 解压到固定目录（建议 `~/development/flutter`）：
   ```bash
   mkdir -p ~/development
   # 把下载的 flutter_*.zip 解压进去
   unzip ~/Downloads/flutter_macos_*.zip -d ~/development
   ```
3. 把 `flutter/bin` 加进 PATH（zsh 是 macOS 默认 shell）：
   ```bash
   # 编辑 ~/.zshrc，追加一行（路径按你实际解压位置改）
   export PATH="$PATH:$HOME/development/flutter/bin"
   source ~/.zshrc
   ```
4. 验证 + 跑环境体检：
   ```bash
   flutter --version
   flutter doctor
   ```

> 想用 fvm 管理版本（可选）：
> ```bash
> brew tap leoafarias/fvm
> brew install fvm
> # 在项目目录锁定版本：fvm install stable && fvm use stable
> ```

### 2. 配 Android（Android Studio 已装）

1. 打开 **Android Studio → Settings → Languages & Frameworks → Android SDK**
2. 装 **Android SDK**（勾一个较新的 Platform，如 API 35）+ **Android SDK Command-line Tools**
3. 打开 **Device Manager → Create Virtual Device**，选一个机型，下载 **系统镜像**（如 API 35 的 arm64 镜像，Apple Silicon 选 arm64 才不卡），建好 AVD
4. 回到终端跑体检确认 Android 工具链绿了：
   ```bash
   flutter doctor -v
   ```
   - 看到 `Android toolchain` 和 `Connected device`（模拟器启动后）为 ✓ 即可。

### 3. 配 iOS（可选，只在你要跑 iPhone 模拟器/真机时做）

> 前提：macOS 26 Tahoe 需装 **Xcode 26**（版本要对上系统）。只跑 Android 可跳过整节。

**A. 下载安装 Xcode（二选一）**
- **方式一 · Mac App Store（推荐）**：打开 App Store → 搜 `Xcode` → 点「获取」安装。需登录 Apple ID，装完在 `/Applications/Xcode.app`。
- **方式二 · 官网点对点下载**：去 https://developer.apple.com/download ，下 `Xcode_26.xip`，双击解压到「应用程序」。
- ⚠️ 体积巨大（下载包 ~7GB+、装完占 20GB+），**至少预留 40–50GB 空闲空间**；下载/解压慢，耐心等。

**B. 首次打开 Xcode**
- 第一次启动会弹「Install additional required components」，点 **Install** 并输密码同意（装额外工具/模拟器支持）。
- 启动后可能显示「Finishing installation」，等它跑完再关。

**C. 命令行许可 + 工具链指向**
```bash
sudo xcodebuild -license accept
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**D. 确保有 iOS 模拟器运行时**（见 Q3）
- Xcode → Settings → Platforms，确认已有一个 iOS 模拟器 runtime（如 iOS 26）；没有就选装。

**E. 装 CocoaPods（iOS 原生依赖管理）**
```bash
brew install cocoapods   # macOS 26 系统 Ruby 已不可用，用 brew 最稳
```

**F. 验证**
```bash
open -a Simulator        # 启模拟器
flutter doctor -v        # 确认 Xcode / iOS toolchain 为 ✓
flutter devices          # 能看到启动的模拟器
```

---

## 四、本工程专属坑（pubspec 依赖需注意）

工程 `pubspec.yaml` 里有两个 **需要原生权限配置** 的依赖，第一次 `flutter pub get` 后可能要补原生文件：

| 依赖 | 作用 | 需要补的原生配置 |
| --- | --- | --- |
| `flutter_local_notifications` | 本地通知 | iOS：在 `ios/Runner/Info.plist` 加通知权限描述；Android：通知 channel（插件已默认，一般不用动） |
| `audioplayers` | 播放提示音 | iOS：音频会话一般在插件内处理；Android：`AndroidManifest.xml` 加 `INTERNET`/`WAKE_LOCK`（按需） |

这两个依赖的官方 README 都有对应原生步骤，遇到运行报错先去对应包文档查，别硬猜。

> 其它依赖（`flutter_riverpod`、`shared_preferences`、`uuid`、`timezone`）是纯 Dart / 自动处理原生层，无需额外配置。

---

## 五、跑起来验证

```bash
cd /Users/xixi/Desktop/个人项目/pomodoro-app/flutter
flutter pub get
flutter doctor          # 确认无致命红叉
flutter run             # 选模拟器/真机，启动 App
```

`flutter doctor` 里 **红叉（✗）** 才是必须解决的；**黄叹号（!）** 大多是可选（比如没装 IntelliJ/VS Code 插件、没连设备），可以先忽略。

---

## 六、版本约束提醒

- 本工程 `environment.sdk` 为 `>=3.3.0 <4.0.0`（Dart 版本）。
- 装 **最新 Stable Flutter** 即可满足（Flutter 3.19+ 自带 Dart 3.3+，远小于 4.0 上限）。
- 不要图新鲜装 **master/dev  channel**，稳定开发用 stable 最省心。

---

## 七、一键自检清单

- [ ] `flutter --version` 能输出版本
- [ ] `flutter doctor` 无红叉
- [ ] Android Studio 里建好一个 AVD 并启动成功
- [ ] （iOS）Xcode 装好、`flutter doctor` 显示 Xcode ✓、Simulator 能开
- [ ] `flutter pub get` 在本工程目录成功
- [ ] `flutter run` 能起 App

---

## 八、常见疑问（FAQ）

### Q1：官方「VS Code 安装」和「手动安装」选哪个？

两者最终用的都是**同一份 Flutter SDK**，区别不在 SDK，而在"要不要顺带装 VS Code"：

- **手动安装**：自己下 SDK 压缩包解压 + 配 `PATH`，编辑器随意（Android Studio / VS Code / 其它都行）。
- **VS Code 安装**：顺带装 VS Code + Flutter/Dart 插件，由插件引导你下载 SDK、配环境。

**推荐你用「手动安装」**：你已经是 Android Studio 用户、命令行也熟，没必要为装 Flutter 再多装一个 VS Code。
（如果你只是想要更轻量的编辑器来写 Flutter 代码，可以单独装 VS Code——但那是编辑器选择，不是"装 Flutter"的方式。新手想一步到位才更适合走 VS Code 引导。）

> **VS Code 装法和 Android Studio 完全不冲突、可共存**：Flutter SDK 只装一份在磁盘上（如 `~/development/flutter`）并写进 `PATH`，哪个 IDE 打开工程都调用同一个 `flutter` 命令。你可以 VS Code 写代码、Android Studio 开模拟器/看布局检查器，或反过来。Android Studio 要识别 Flutter，只需在插件市场装一下 Flutter + Dart 插件即可。

### Q2：`xcode-select --install` 和 `--switch` 分别是干啥的？

| 命令 | 作用 | 你本机现状 |
| --- | --- | --- |
| `xcode-select --install` | 安装 **Command Line Tools（CLT）**：clang、git、make、`xcodebuild` 等命令行编译工具，几百 MB，**不需要完整 Xcode.app** | ✅ 已装 26.6.0，这步已完成 |
| `xcode-select --switch /Applications/Xcode.app/Contents/Developer` | 切换"当前默认用哪套开发者工具链"。只有装了**完整 Xcode.app** 后才需要把它指过去，让 `flutter`/`xcodebuild` 调用 Xcode 里的完整工具链 | ❌ 没装 Xcode，暂不需要 |

一句话记：
- `--install` = **把工具包装上**（你已装，再跑会提示已安装）
- `--switch` = **多套工具链里选默认**（仅装了完整 Xcode 才用，路径不存在时切会报错）

  **白话版**：把你电脑想象成有多个「工具箱」——只装 CLT 是个「小工具箱」（含基础编译命令），装了完整 Xcode 是个「大工具箱」（含 iOS 编译全套）。`xcode-select` 就是「选择当前默认用哪个工具箱」的开关；`--switch /Applications/Xcode.app/Contents/Developer` 就是告诉系统：「以后编译 iOS，用 Xcode 这个大工具箱里的工具，别用小的。」只有你真装了完整 Xcode.app 才需要这一刀切，否则系统默认用 CLT 就够了。

### Q3：装完 Xcode 自带 iPhone 模拟器吗？

自带**模拟器 App（Simulator）**，但要分清「模拟器软件」和「模拟器里的 iPhone」：

- Xcode 安装后自带 `Simulator.app`，装完就能 `open -a Simulator` 打开。
- 但模拟器里能跑的「一台 iPhone + 某个 iOS 版本」叫**模拟器运行时（Simulator Runtime）**，新版 Xcode（15+）它是**按需下载**的：装完通常会带/提示下载一个最新版（如 Xcode 26 自带 iOS 26），否则去 **Xcode → Settings → Platforms** 里选装想要的版本/机型。
- Apple Silicon Mac 上模拟器是原生 arm64，速度很快。
- 注意：模拟器**测不了真机专属硬件**（相机、蓝牙、真实推送通知等），日常 UI/逻辑开发够用；要测这些得上真机。
- Flutter 侧确认：模拟器启动后 `flutter devices` 能看到；`flutter doctor` 的 iOS 部分变绿即可。

官方让你"先装 CLT 再 switch"的逻辑：原生编译（尤其 iOS）依赖这些命令行工具，先保证 CLT 保底，再决定要不要上完整 Xcode。

**对你实际的建议：**
- 只跑 Android → **两个都不用管**。CLT 已满足，`flutter doctor` 里 Xcode 那行的报错（黄叹号）可忽略。
- 要跑 iOS → 才需要：App Store 装 Xcode 26 → `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` → `sudo xcodebuild -license accept`。
