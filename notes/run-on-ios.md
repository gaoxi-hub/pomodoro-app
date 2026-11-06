# 在 iOS 模拟器运行 Flutter 项目

> 适用：Apple Silicon Mac（arm64）· 项目 `pomodoro-app/flutter/`
> 前提：Flutter 代码已写完（本文只讲「怎么跑起来」）
> 实测环境：macOS 26.6.2 + Xcode 27.2 + Flutter 3.47.8

---

## 一、安装 Xcode（只做一次）

### 1. 装 Xcode

**方式 A：App Store（最省事）**

打开 App Store 搜 `Xcode` → 安装。体积约 10GB+，下载看网速。

**方式 B：官网下载（App Store 卡住时用）**

去 [developer.apple.com/download/all](https://developer.apple.com/download/all/) 搜 Xcode，下载 `.xip`，解压后把 `Xcode.app` 拖进 `/Applications`。

### 2. 指向 Xcode 并同意协议

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -runFirstLaunch      # 装内建组件，第一次必跑
```

验证：

```bash
xcodebuild -version              # 应输出 Xcode 27.x
xcrun simctl list runtimes       # 应能看到 iOS 27.x 的 runtime
```

> 如果 `xcrun simctl list runtimes` 是空的，说明模拟器系统镜像没装。打开 Xcode → `Settings → Components`（或 `Platforms`）→ 下载一个 iOS 模拟器 runtime。

### 3. 关于 iOS 27 的重要变化

**Xcode 27 里已经没有独立的 `Simulator.app` 了**，苹果把它合并进了 `DeviceHub.app`。所以：

| 你以前的做法 | 现在应该怎么做 |
| --- | --- |
| `open -a Simulator` | ❌ 报 `Unable to find application named 'Simulator'` |
| — | ✅ `open -b com.apple.dt.Devices` |
| — | ✅ Xcode 菜单 → `Open Developer Tool` → `DeviceHub` |

`DeviceHub.app` 的实际位置：`/Applications/Xcode.app/Contents/Applications/DeviceHub.app`

---

## 二、安装 CocoaPods

Flutter 的 iOS 插件（`flutter_local_notifications` 等）靠 CocoaPods 管理，**不装就一定编译失败**。

```bash
brew install cocoapods
pod --version        # 有版本号即可（实测 1.17.0）
```

> ⚠️ **不要用 `sudo gem install cocoapods`**。macOS 自带 Ruby 是 2.6.10，新版 CocoaPods 要求 Ruby ≥ 2.7，装不上或者装完跑不起来。Homebrew 会自己带一份合适的 Ruby。

---

## 三、一条龙命令（最快路径）

```bash
# 1. 环境
export PATH="$HOME/env/flutter/bin:$PATH"
cd /Users/xixi/Desktop/个人项目/pomodoro-app/flutter

# 2. 生成 iOS 工程（只需一次；重复执行也安全，幂等）
flutter create . --platforms=ios

# 3. 启动模拟器（Xcode 27 用 DeviceHub）
#    · 已经用图形界面开好模拟器 → 这两行整段跳过
xcrun simctl boot "iPhone 18 Pro" 2>/dev/null || true   # 后台开机（看不见窗口）
open -b com.apple.dt.Devices                            # 打开 DeviceHub 窗口

# 4. 确认设备（要能看到 iPhone 18 Pro，记下它的 UUID）
flutter devices

# 5. 运行（UUID 换成上一步实际看到的）
flutter run -d A7C761AB-E22E-45B4-BA30-8A140F52D564
```

> ⚠️ 上面那个 UUID 只是示例，**每次重建模拟器都可能变**，务必以 `flutter devices` 的输出为准。

第 5 步第一次会自动做三件事：`pod install` → 解析 Swift Package → 编译。2–5 分钟正常，之后增量很快。

---

## 四、分步说明

### 1. 生成 `ios/` 目录

```bash
cd /Users/xixi/Desktop/个人项目/pomodoro-app/flutter
flutter create . --platforms=ios
```

这会在 `flutter/ios/` 下生成 `Runner.xcodeproj`、`Runner.xcworkspace`、`Podfile` 等。**不会动 `lib/` 里的任何 Dart 代码**，可以放心跑。

### 2. 启动模拟器

```bash
# 看有哪些模拟器
xcrun simctl list devices available

# 启动指定机型（后台运行时，看不见窗口）
xcrun simctl boot "iPhone 18 Pro"

# 打开可视化窗口（DeviceHub）
open -b com.apple.dt.Devices
```

**这两条命令分工完全不同，别当成一回事：**

| 命令 | 做什么 | 有窗口吗 |
| --- | --- | --- |
| `xcrun simctl boot` | 把虚拟 iPhone **开机**（后台进程） | ❌ 什么都看不见 |
| `open -b com.apple.dt.Devices` | 打开 **DeviceHub** 图形界面 | ✅ 只是「看画面」的窗口 |

所以纯命令行环境下必须两条都跑，否则能 `flutter run` 但屏幕上没东西。

**用图形界面启动可以完全跳过这两条**——在 DeviceHub 里点一下启动，等于同时做了 `boot` + 开窗口：

1. `Cmd + 空格` 搜 `DeviceHub` 回车（或 Xcode 菜单 → `Open Developer Tool` → `DeviceHub`）
2. 左侧边栏选中 `iPhone 18 Pro`
3. 点启动 → 设备开机 + 手机窗口出现

之后直接 `flutter run` 即可（只有一台在跑时连 `-d` 都不用带）。

> **关于 `2>/dev/null || true`**：对已经开机的设备再执行一次 `boot` 会报错——
> `Unable to boot device in current state: Booted`（domain=Simulator.SimError, code=405，退出码 149）。
> 加 `|| true` 是为了让重复执行不中断脚本（幂等）。**成功时 `simctl` 不打印任何东西**，没有输出是正常的。

### 3. 拿设备 id 并运行

```bash
flutter devices
# iPhone 18 Pro (mobile) • A7C761AB-E22E-45B4-BA30-8A140F52D564 • ios • ...
```

`-d` 后面跟的是那串 **UUID**（注意跟 Android 的 `emulator-5554` 形态完全不同）。

```bash
flutter run -d A7C761AB-E22E-45B4-BA30-8A140F52D564
```

### 4. 或者完全用 Xcode 图形界面跑

不想用命令行时：

1. Xcode → `File → Open...`
2. 选 `flutter/ios/Runner.xcworkspace` ← **必须是 `.xcworkspace`**
3. 顶部工具栏设备下拉选 `iPhone 18 Pro`
4. 点 ▶（`Cmd + R`）

> `.xcworkspace` 和 `.xcodeproj` 的区别：前者包含 CocoaPods 拉进来的插件工程，后者不含。**选错 `.xcodeproj` 会满屏 `Module not found`**。如果 workspace 里看不到 Pods 项目，说明 `pod install` 没跑过。

> Xcode 里 Run 只是编译安装，**没有 Flutter 热重载**。要热重载还是得用 `flutter run`。

---

## 五、踩过的坑（都真实遇到过）

### ① `open -a Simulator` 报找不到应用

Xcode 27 的变化，见第一节第 3 点。改用 `open -b com.apple.dt.Devices`。

### ② `pod install` 报 SSL 证书错误

```
SSL_connect returned=1 errno=0 state=error: certificate verify failed
(Unable to get local issuer certificate)
```

本机开代理时容易撞到。指定 CA 证书绕过：

```bash
cd ios
SSL_CERT_FILE=/opt/homebrew/etc/ca-certificates/cert.pem pod install
cd ..
```

### ③ SPM 解析失败：`sandbox_apply: Operation not permitted`

Flutter 3.47 默认启用 **Swift Package Manager**，`audioplayers`、`shared_preferences` 走 SPM 而不是 CocoaPods。如果 SPM 解析不出来，可以整体退回 CocoaPods：

```bash
flutter config --no-enable-swift-package-manager
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..
flutter run -d <UUID>
```

这是全局配置，会影响其他 Flutter 项目；要恢复就 `flutter config --enable-swift-package-manager`。

### ④ Podfile 警告 `did not set the base configuration`

Flutter 项目的 `Flutter/Debug.xcconfig` 已经用 `#include?` 做了可选包含，这个警告**对 Flutter 项目是无害的**，忽略即可。

### ⑤ iOS 上白噪音完全没声音 —— OGG 格式不支持

这是本项目实际踩到的：14 个环境音原本是 `.ogg`（Vorbis），**iOS 的 AVPlayer 原生不支持 OGG**，调播放接口会静默失败。

解决办法是全部转成 MP3：

```bash
cd flutter/assets/audio
for f in *.ogg; do
  ffmpeg -y -v error -i "$f" -codec:a libmp3lame -b:a 128k -ar 44100 -ac 2 "${f%.ogg}.mp3"
done
```

然后把 `lib/core/models/noise_sound.dart` 里的 `.ogg` 全改 `.mp3`。

> 另外提醒：`audioplayers` 的 `AudioCache` 默认 `prefix='assets/'`，所以传路径要写 `AssetSource('audio/ding.wav')`，**不能写成 `AssetSource('assets/audio/ding.wav')`**，否则会拼成 `assets/assets/...` 找不到文件。

### ⑥ 模拟器不需要签名

模拟器跑不需要 Apple Developer 账号，也不用配 Team。只有装到真机或上架才需要。

### ⑦ `simctl boot` 没有任何输出，是不是没成功？

**成功就是没有输出**。`simctl` 成功时静默返回 0。

真正会报错的是"重复开机"（已 Booted 时再 boot 一次）：

```
An error was encountered processing the command (domain=com.apple.CoreSimulator.SimError, code=405):
Unable to boot device in current state: Booted
退出码: 149
```

所以脚本里写 `xcrun simctl boot "iPhone 18 Pro" 2>/dev/null || true`，让这个重复操作不中断流程。

想确认到底开没开，看这个：

```bash
xcrun simctl list devices booted      # 有 (Booted) 就是开了
```

### ⑧ 按名字启动可能启动错机器

本机曾出现**两台同名 `iPhone 18 Pro`**（新建机型时重复添加），`xcrun simctl boot "iPhone 18 Pro"` 只会启动其中一台，**可能不是你在 DeviceHub 里点开的那台**。同名设备删掉后就正常了，但保险做法还是先查 UUID：

```bash
xcrun simctl list devices available | grep "iPhone 18 Pro"
# iPhone 18 Pro (A7C761AB-E22E-45B4-BA30-8A140F52D564) (Booted)
```

用 UUID 精确启动：

```bash
xcrun simctl boot A7C761AB-E22E-45B4-BA30-8A140F52D564
```

嫌乱可以在 DeviceHub 里右键删掉多余那台，或改个名字区分。

### ⑨ Bundle ID 还是 `com.example.pomodoro`

模拟器测试无所谓，上架前必须改（`ios/Runner.xcodeproj/project.pbxproj` 里的 `PRODUCT_BUNDLE_IDENTIFIER`，以及 `ios/Runner/Info.plist` 的 `CFBundleDisplayName`）。

---

## 六、验证清单

- [ ] App 能装进模拟器并启动，不闪退
- [ ] 主页极简版渲染正常（无 Android 上的字体/间距差异）
- [ ] 点「开始」倒计时正常走
- [ ] 主页 🔊 打开白噪音，选一个音能出声（**iOS 上这步最容易暴露格式问题**）
- [ ] 专注时长调 1 分钟，结束时能听到「叮」
- [ ] 首次启动会弹通知权限，允许后通知正常

## 七、常用命令速查

```bash
flutter devices                        # 列出设备（iOS 是 UUID）
flutter run -d <UUID>                  # 运行
flutter run --release -d <UUID>        # release 模式
xcrun simctl list devices available    # 列出模拟器（含 UUID + 状态）
xcrun simctl list devices booted       # 只看已开机的
xcrun simctl boot "iPhone 18 Pro"      # 启动指定机型（后台，无窗口；成功时无输出）
xcrun simctl shutdown all              # 关掉全部模拟器
open -b com.apple.dt.Devices           # 打开 DeviceHub 窗口（等价于「看屏幕」）
open ios/Runner.xcworkspace            # 用 Xcode 打开项目
flutter clean                          # 清缓存
```

> **图形界面替代**：DeviceHub 里点一次启动 = `simctl boot` + `open -b com.apple.dt.Devices` 两步合一，之后直接 `flutter run` 就行。

## 八、下一步（上架前要做的）

模拟器跑通只是第一步，真要上架还得处理：

1. 改 Bundle ID 为自有域名反写（如 `com.yourname.pomodoro`）
2. 替换 App 图标（`ios/Runner/Assets.xcassets/AppIcon.appiconset/`）
3. 配置签名证书 + Provisioning Profile（需 Apple Developer 账号，¥688/年）
4. App Store Connect 建应用、填元数据、截图、送审
