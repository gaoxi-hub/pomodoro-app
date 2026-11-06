# 在 Android 模拟器运行 Flutter 项目

> 适用：Apple Silicon Mac · 项目 `pomodoro-app/flutter/`  
> 前提：Flutter 代码已写完（本文只讲「怎么跑起来」，不讲怎么写代码）

---

## 一、先确认三件事

```bash
export PATH="$HOME/env/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$PATH"

flutter --version     # 有版本号 = SDK 就绪
flutter doctor        # 看 Android toolchain 是否 ✓
adb devices           # 看模拟器有没有在线
```

`flutter doctor` 里 **Android toolchain 必须是 ✓**。如果是 ✗，说明 Android SDK 路径没配好，先在 Android Studio 的 Settings → Languages & Frameworks → Android SDK 里装好 SDK，并把 `sdk.dir` 写进 `android/local.properties`。

> ⚠️ **Flutter 和 adb 都没进系统 PATH**。Flutter 在 `~/env/flutter/bin`，adb 在 `~/Library/Android/sdk/platform-tools`。所以每开一个新终端，第一件事就是执行上面那行 `export PATH=...`，否则会报 `command not found: flutter` 或 `command not found: adb`。
>
> 想一劳永逸就直接写进 `~/.zshrc`：
>
> ```bash
> echo 'export PATH="$HOME/env/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$PATH"' >> ~/.zshrc
> source ~/.zshrc
> ```

---

## 二、一条龙命令（最快路径）

```bash
# 1. 环境
export PATH="$HOME/env/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$PATH"
cd /Users/xixi/Desktop/个人项目/pomodoro-app/flutter

# 2. 启动模拟器（已启动可跳过）
~/Library/Android/sdk/emulator/emulator -avd Pixel_8 &

# 3. 等它起来（看到 emulator-xxxx device 再继续）
#adb devices
flutter devices 


# 4. 运行
flutter run -d emulator-5554
```

第一次会构建 1–3 分钟（要拉 NDK / CMake），之后增量构建几秒到几十秒。

---

## 三、分步说明

### 1. 启动模拟器

**方式 A：Android Studio 图形界面（推荐新手）**

`Tools → Device Manager` → 找到 `Pixel_8` → 点 ▶ 启动。

**方式 B：命令行**

```bash
~/Library/Android/sdk/emulator/emulator -avd Pixel_8 &
```

**怎么知道它的 device id？**

```bash
adb devices
# List of devices attached
# emulator-5554	device      ← 这个就是 id
```

> ⚠️ **最容易踩的坑**：`Pixel_8` 是 AVD 的**名字**，不是设备 id。`flutter run -d Pixel_8` 会报 `No devices found`，必须用 `emulator-5554`。

### 2. 跑起来

```bash
flutter run -d emulator-5554
```

不带 `-d` 也行——只有一台设备在线时它会自动选；多台设备（比如 Android + iOS 同时开着）会列出来让你输数字选。

### 3. 日常开发循环

跑起来后，终端里支持这些快捷键：

| 按键  | 作用                          |
| --- | --------------------------- |
| `r` | 热重载（改 UI 用这个，秒级生效）          |
| `R` | 热重启（改了 initState / 全局状态用这个） |
| `q` | 退出                          |

改完代码如果热重载没反应，多半是改了 `StatefulWidget` 的字段或 Provider 初始化逻辑，用 `R` 热重启。

### 4. 只装 APK 不调试

```bash
flutter build apk --debug
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
```

> `flutter install` 有个坑：它默认找 **release** APK，如果你只构建了 debug 包会失败。直接用 `adb install` 更省事。

---

## 四、踩过的坑（都真实遇到过）

### ① `flutter run -d Pixel_8` → No devices found

AVD 名字 ≠ 设备 id。用 `adb devices` 查到的 `emulator-5554`。

### ② 构建中断，exit code 143

143 = SIGTERM，通常是**两个 `flutter run` 抢同一个 Gradle daemon**，互相把对方杀了。解决：

```bash
pkill -f 'flutter run'; pkill -f 'GradleDaemon'; pkill -f 'gradle'
flutter clean
rm -rf ~/.gradle/daemon
```

然后确保**只有一个** `flutter run` 在跑。

### ③ Gradle 报证书错误（`certificate verify failed` on dl.google.com）

本机开着代理时会出现。构建时临时绕开代理：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy flutter run -d emulator-5554
```

### ④ `flutter_local_notifications` 要求 core library desugaring

`android/app/build.gradle.kts` 里必须开：

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

否则编译直接报错。

### ⑤ 通知权限不生效

`android/app/src/main/AndroidManifest.xml` 里要有：

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

> 注意：**别在启动时就申请精确闹钟权限**（`requestExactAlarmsPermission`），它会直接把用户弹到系统设置页，体验很差。正确做法是启动只申请通知权限，精确闹钟在真正调度时静默降级成非精确。

### ⑥ 模拟器完全没声音

**先别怀疑代码。** Android 模拟器的音频路由经常不通，即使 App 正确调用了播放接口也不出声。判断方法：用真机跑一次同样的操作，真机有声 = 代码没问题，纯模拟器限制。

### ⑦ 每次冷启动都跳到系统设置页

就是上面 ⑤ 说的精确闹钟权限问题，改成静默降级即可。

### ⑧ 报 `command not found: adb`

adb 装在 `~/Library/Android/sdk/platform-tools/adb`，只是没进 PATH。三种解法：

```bash
# 临时（当前终端有效）
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# 永久
echo 'export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"' >> ~/.zshrc && source ~/.zshrc

# 或者干脆不用 adb
flutter devices    # 查设备 id
flutter run        # 直接跑
```

**跑 App 其实不依赖 adb**，adb 只在需要「直接装包、看原始日志、强杀进程」时才用得上。

---

## 五、验证清单

跑起来后按顺序过一遍：

- [ ] 主页能正常渲染（计时环、模式切换、开始/重置按钮）
- [ ] 点「开始」倒计时在走，且切后台再回来时间是对的（时间戳计时，不掉秒）
- [ ] 主页 🔊 打开白噪音面板，选一个音能出声
- [ ] 把专注时长调到 1 分钟，等结束能听到「叮」+ 收到通知
- [ ] 任务页能建任务，主页能绑定任务
- [ ] 统计页日/周/月切换正常

## 六、常用命令速查

```bash
flutter devices                       # 列出所有设备
flutter run -d emulator-5554          # 运行
flutter run --release -d emulator-5554  # release 模式（性能接近真机）
flutter clean                         # 清构建缓存（玄学问题先来一发）
flutter logs -d emulator-5554         # 只看日志
adb -s emulator-5554 emu kill         # 关掉模拟器
```
