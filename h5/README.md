# h5/ — 番茄钟 App 前端（H5）

本目录是番茄钟 App 的**纯前端 H5 工程根目录**。

- 技术栈：Vue 3 + TypeScript + Vite + Pinia + Vue Router
- 约束：**纯前端、无后端、无用户体系**；数据全部存浏览器 `localStorage`（键前缀 `pomodoro:`）
- 视觉：严格照 `../design/DESIGN.md`，还原基准 `../design/番茄钟App-高保真原型.html`

## 初始化（按 `../开发计划.md` S1）
脚手架在本目录内建立 `package.json`、`index.html`、`src/` 等。详见仓库根 `开发计划.md` 第一步。

## 目录规划（S1 后落成）
```
h5/
  index.html  package.json  vite.config.ts  tsconfig.json
  src/
    main.ts  App.vue  router/index.ts
    styles/tokens.css        # 设计令牌（来自 DESIGN.md，必建）
    styles/global.css
    types/index.ts           # Task / PomodoroSession / Settings 类型
    stores/  tasks timer settings stats achievements
    composables/  useTimer useAudio useNotify useStorage
    components/  AppShell TabBar BottomSheet GlassCard PillMetric TimerRing
                 TaskCard PomodoroBar StatChart GemCard Switch Stepper
    views/  HomeView TasksView StatsView SettingsView
    sheets/  AddTaskSheet PickTaskSheet
    assets/audio/            # 白噪音素材（S11）
```
