# AGENTS.md — 番茄钟 App

> 本文件供 AI 编码代理（WorkBuddy / Claude Code / Codex 等）阅读，用于快速理解项目并高效协作。
> 每次新会话开始开发前，**先通读本文件**，再按需读取下方"文档索引"中的对应章节。

---

## 1. 项目简介

- **产品**：番茄钟 App —— 基于番茄工作法（25 分钟专注 + 5 分钟休息循环）的轻量专注计时与任务管理工具。
- **形态**：**纯前端 H5**（移动端优先）。
- **核心闭环**：建任务（含预估番茄数）→ 主页选任务绑定 → 计时专注 → 完成番茄 → 任务进度 +1、统计累加。
- **目标用户**：易分心 / 需要深度工作的学生与知识工作者。

## 2. 关键约束（必须遵守）

1. **纯前端，无后端**：禁止引入后端服务、数据库、登录注册、JWT、云同步。
2. **数据全部存浏览器**：使用 `localStorage`，所有键统一前缀 `pomodoro:`（见第 7 节数据模型）。
3. **单一视觉主题**：暗黑沉浸 + 荧光薄荷绿，严格照 `design/DESIGN.md`，无浅色主题。
4. **不引 UI 组件库**：为保留 Opal 定制外观，UI 用组件化手写 + CSS 变量，不装 Element/Naive 等。
5. **计时精度**：用时间戳法（记录目标结束时间，按 `Date.now()` 计算剩余），禁止 `setInterval` 累加秒数。

## 3. 技术栈

| 层 | 选型 |
| --- | --- |
| 框架/语言 | Vue 3（`<script setup>` + Composition API）+ TypeScript + Vite |
| 状态 | Pinia（各域一个 store，localStorage 持久化） |
| 路由 | Vue Router（主页/任务/统计 三视图；设置由主页齿轮进入） |
| 样式 | CSS 变量（设计令牌）+ 组件 scoped CSS |
| 计时 | 自研 `useTimer` composable（时间戳精确计时） |
| 声音 | Web Audio API 合成提示音 |
| 通知 | Web Notifications API |
| 图表 | 手写 SVG 柱状图（不引第三方图表库） |
| 构建/部署 | 静态产物 `dist/`，托管于 Vercel / Netlify / Cloudflare Pages / WorkBuddy cloud-service |

## 4. 仓库结构

```
番茄钟-app/
  AGENTS.md                 # 本文件（项目说明书，AI 必读）
  开发计划.md               # S1–S13 分步开发计划（每步独立会话）
  PRDs/
    番茄钟App-PRD.md        # 产品需求文档（P0/P1/P2 功能）
    番茄钟App-原型.html      # 线框稿
  design/
    DESIGN.md               # 视觉设计规范（必读，含 CSS 变量）
    番茄钟App-高保真原型.html # UI 还原基准（逐页比对）
  h5/                       # ★ 前端 H5 工程根目录（Vue3 项目在此）
  ios/  android/            # 预留目录（未来原生/跨端，当前为空）
```

前端所有代码位于 **`h5/`**（即 Vue 工程根）。详见 `h5/README.md`。

## 5. 如何开始（H5）

```bash
cd h5
npm install
npm run dev      # 本地开发
npm run build    # 生产构建，产物 dist/
```

S1 负责初始化该工程（脚手架、设计令牌、应用外壳）。在此之前 `h5/` 仅有 `README.md`。

## 6. 编码约定

- TypeScript 严格模式；类型集中在 `h5/src/types/index.ts`。
- 设计令牌只用 `styles/tokens.css` 的变量，**禁止硬编码颜色/圆角**。
- 组件用 `<script setup lang="ts">`；复用 UI 抽成 `components/`，页面级为 `views/`，弹层为 `sheets/`。
- store 暴露 `state + actions`；持久化通过 `useStorage` 在 actions 内写 localStorage。
- 数据模型字段与 localStorage key **严格按第 7 节**，避免破坏上游步骤产物。

## 7. 数据模型契约（全项目统一）

键前缀 `pomodoro:`。

**Task**（任务）
```ts
{ id:string, name:string, estimate:number(>=1), done:number,
  createdAt:number /*epoch ms*/, archived?:boolean }
```
key：`pomodoro:tasks` → `Task[]`

**PomodoroSession**（每次计时记录，统计用）
```ts
{ id:string, taskId:string|null, type:'work'|'short'|'long',
  startedAt:number, endedAt:number, plannedMin:number, completed:boolean }
```
key：`pomodoro:sessions` → `PomodoroSession[]`

**Settings**
```ts
{ workMin:25, shortMin:5, longMin:15, longBreakInterval:4,
  autoStartNext:true, breakEndNotify:true, eyeCare20:false,
  celebrate:true, soundOn:true, whiteNoise:'off' }
```
key：`pomodoro:settings`

**其它**
- `pomodoro:currentTaskId` → `string|null`
- `pomodoro:goal` → `{ dailyPomodoros:number }`（默认 8）
- `pomodoro:achievements` → `string[]`

**派生统计**：今日番茄数 = 当日 `type==='work' && completed` 的 session 数；专注时长 = 其 `plannedMin` 之和；连续天数 = 含今日/昨日向前连续有 ≥1 完成工作 session 的天数。

## 8. 文档索引（按需深读）

| 文档 | 用途 | 何时读 |
| --- | --- | --- |
| `PRDs/番茄钟App-PRD.md` | 功能定义（P0/P1/P2） | 做任何功能前 |
| `design/DESIGN.md` | 视觉规范、CSS 变量、组件规范、验收清单 | 写任何 UI 前 |
| `design/番茄钟App-高保真原型.html` | 逐页 UI 还原基准 | 写页面/组件时对照 |
| `开发计划.md` | S1–S13 分步任务、依赖、完成标准 | 领到某一步任务时读对应步骤 + 第二节通用上下文 |

## 9. 开发工作流（逐步新开会话）

1. 按 `开发计划.md` 的 **S1 → S13** 顺序推进；每步建议**新开一个会话**完成。
2. 每个新会话：先读本 `AGENTS.md` + 开发计划对应步骤 + 其"依赖前置"已完成的 store/组件。
3. 严格复用既有类型字段与 localStorage key，不破坏上游。
4. 每步完成跑 `npm run build` 确保无 TypeScript / 构建错误再交付。
5. UI 还原以高保真原型为准，对照 `DESIGN.md` 第十节验收清单。

## 10. 里程碑

- **M1（S1–S6）**：核心闭环可用 —— 建任务、选任务、计时、完成、统计、反馈。
- **M2（S7–S10）**：可用产品 —— 任务管理、历史趋势、自定义规则、休息/护眼提醒。
- **M3（S11–S13）**：体验完整 —— 白噪音、成就宝石、每日目标与导出。

## 11. 常见坑

- 不要把时长/间隔硬编码在组件里，必须读 `settings` store（S9 起）。
- 番茄"完成"判定以**工作番茄完整结束**为准；中断（`completed=false`）不计统计、不触发庆祝。
- 切换日/周/月统计只聚合 `type==='work' && completed` 的 session。
- 发光效果只给焦点元素（倒计时/主数字/主按钮），勿滥用。
