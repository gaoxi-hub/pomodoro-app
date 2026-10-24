<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useTimer } from '../composables/useTimer'
import { useTasksStore } from '../stores/tasks'
import { useStatsStore } from '../stores/stats'
import { useSettingsStore } from '../stores/settings'
import { useNoiseMixer } from '../composables/useNoiseMixer'
import TimerRing from '../components/TimerRing.vue'
import PillMetric from '../components/PillMetric.vue'
import PomodoroBar from '../components/PomodoroBar.vue'
import PickTaskSheet from '../sheets/PickTaskSheet.vue'
import NoiseSheet from '../sheets/NoiseSheet.vue'

const router = useRouter()
const timer = useTimer()
const tasks = useTasksStore()
const stats = useStatsStore()
const store = useSettingsStore()
const noise = useNoiseMixer()

const noiseOpen = ref(false)
const noiseActive = computed(() => noise.anyOn(store.settings.noise))

const modes = [
  { key: 'work', label: '工作' },
  { key: 'short', label: '短休' },
  { key: 'long', label: '长休' },
] as const

const pickOpen = ref(false)

const timeText = computed(() => {
  const s = timer.remainingSec
  const m = Math.floor(s / 60)
  const sec = s % 60
  return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`
})

const modeLabel = computed(
  () =>
    ({ work: 'FOCUS', short: 'SHORT BREAK', long: 'LONG BREAK' })[timer.mode],
)

const subText = computed(() => {
  if (timer.mode === 'work') return `第 ${stats.todayPomodoros + 1} 个番茄`
  return timer.mode === 'short' ? '短休息' : '长休息'
})

function toggle() {
  if (timer.status === 'running') timer.pause()
  else timer.start()
}

function fmtMin(m: number): string {
  if (m >= 60) return `${Math.floor(m / 60)}h${m % 60 ? (m % 60) + 'm' : ''}`
  return `${m}m`
}

function onPick(id: string | null) {
  tasks.setCurrentTask(id)
}

// 完成绿光脉冲
const pulsing = ref(false)
let pulseTimer: ReturnType<typeof setTimeout> | null = null
watch(
  () => timer.pulseTrigger,
  () => {
    pulsing.value = true
    if (pulseTimer) clearTimeout(pulseTimer)
    pulseTimer = setTimeout(() => (pulsing.value = false), 600)
  },
)
</script>

<template>
  <div class="home">
    <div class="topbar">
      <h1>专注</h1>
      <div class="top-actions">
        <button class="icon-btn" :class="{ on: noiseActive }" @click="noiseOpen = true" title="环境音">
          🔊
        </button>
        <button class="icon-btn" @click="router.push('/settings')">⚙️</button>
      </div>
    </div>

    <div class="mode-row">
      <button
        v-for="m in modes"
        :key="m.key"
        class="mode-pill"
        :class="{ active: timer.mode === m.key }"
        @click="timer.setMode(m.key)"
      >
        {{ m.label }}
      </button>
    </div>

    <TimerRing :progress="timer.progress" :mode="timer.mode" :size="236">
      <div class="mode-label">{{ modeLabel }}</div>
      <div class="time">{{ timeText }}</div>
      <div class="sub">{{ subText }}</div>
    </TimerRing>

    <div class="controls">
      <button class="btn btn-ghost" @click="timer.reset()">重置</button>
      <button
        class="btn btn-primary"
        :class="{ running: timer.status === 'running' }"
        :aria-label="timer.status === 'running' ? '暂停' : '开始'"
        @click="toggle"
      >
        <svg
          v-if="timer.status === 'running'"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="currentColor"
        >
          <path d="M6 5h4v14H6zM14 5h4v14h-4z" />
        </svg>
        <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
          <path d="M8 5v14l11-7z" />
        </svg>
        <span>{{ timer.status === 'running' ? '暂停' : '开始' }}</span>
      </button>
      <button class="btn btn-ghost" @click="timer.skip()">跳过</button>
    </div>

    <div class="task-now glass" @click="pickOpen = true">
      <div class="lbl">
        <span>Current Task</span>
        <span class="change">点击切换 ›</span>
      </div>
      <template v-if="tasks.currentTask">
        <div class="name">{{ tasks.currentTask.name }}</div>
        <div class="prog">
          <span>已投入 {{ tasks.currentTask.done }} / 预估 {{ tasks.currentTask.estimate }} 🍅</span>
          <span class="pct">
            {{
              tasks.currentTask.estimate > 0
                ? Math.round((tasks.currentTask.done / tasks.currentTask.estimate) * 100)
                : 0
            }}%
          </span>
        </div>
        <PomodoroBar
          :done="tasks.currentTask.done"
          :estimate="tasks.currentTask.estimate"
        />
      </template>
      <template v-else>
        <div class="name muted">未选择任务</div>
        <div class="prog"><span>点击此处绑定一个专注任务</span></div>
      </template>
    </div>

    <div class="pills">
      <PillMetric icon="🍅" :value="stats.todayPomodoros" label="今日番茄" />
      <PillMetric icon="⏱️" :value="fmtMin(stats.todayFocusMinutes)" label="专注时长" />
      <PillMetric icon="🔥" :value="stats.streak" label="连续天数" variant="energy" />
    </div>

    <PickTaskSheet v-model="pickOpen" @pick="onPick" />
    <NoiseSheet v-model="noiseOpen" />

    <div v-if="pulsing" class="pulse"></div>
  </div>
</template>

<style scoped>
.home {
  position: relative;
}
.topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 -20px 12px;
  padding: 10px 20px 12px;
  background: #000;
}
.topbar h1 {
  font-size: 30px;
  font-weight: 700;
  letter-spacing: -0.5px;
}
.icon-btn {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}
.top-actions {
  display: flex;
  gap: 10px;
}
.icon-btn.on {
  border-color: var(--accent);
  color: var(--accent);
  box-shadow: var(--glow-soft);
}
.mode-row {
  display: flex;
  gap: 8px;
  justify-content: center;
  margin-bottom: 16px;
}
.mode-pill {
  padding: 8px 16px;
  border-radius: var(--radius-pill);
  font-size: 13px;
  font-weight: 600;
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: var(--text-secondary);
}
.mode-pill.active {
  background: rgba(127, 255, 212, 0.12);
  border-color: var(--accent);
  color: var(--accent);
  box-shadow: var(--glow-soft);
}
.time {
  font-size: 60px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  letter-spacing: -2px;
  text-shadow: var(--glow-accent);
}
.mode-label {
  font-size: 13px;
  letter-spacing: 2px;
  color: var(--accent);
  font-weight: 600;
  margin-bottom: 4px;
}
.sub {
  font-size: 13px;
  color: var(--text-secondary);
  margin-top: 6px;
}
.controls {
  display: flex;
  gap: 12px;
  justify-content: center;
  align-items: center;
  margin: 14px 0 18px;
}
.btn {
  padding: 12px 24px;
  border-radius: var(--radius-pill);
  font-size: 15px;
  font-weight: 600;
  border: none;
  display: flex;
  align-items: center;
  gap: 6px;
}
.btn-primary {
  background: var(--accent-gradient);
  color: #04201a;
  box-shadow: 0 0 16px rgba(127, 255, 212, 0.45);
  min-width: 116px;
  justify-content: center;
}
.btn-primary:active {
  transform: scale(0.96);
}
.btn-primary.running {
  background: rgba(127, 255, 212, 0.14);
  border: 1px solid var(--accent);
  color: var(--accent);
  box-shadow: var(--glow-soft);
}
.task-now {
  padding: 14px 18px;
  margin-bottom: 14px;
  cursor: pointer;
  transition: 0.2s;
}
.task-now:active {
  transform: scale(0.98);
}
.task-now .lbl {
  font-size: 11px;
  letter-spacing: 1.5px;
  color: var(--text-tertiary);
  text-transform: uppercase;
  margin-bottom: 6px;
  display: flex;
  justify-content: space-between;
}
.task-now .lbl .change {
  color: var(--accent);
}
.task-now .name {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 10px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.task-now .name.muted {
  color: var(--text-tertiary);
}
.task-now .prog {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text-secondary);
  margin-bottom: 6px;
}
.task-now .pct {
  color: var(--accent);
}
.pills {
  display: flex;
  gap: 10px;
}
.pulse {
  position: fixed;
  inset: 0;
  background: radial-gradient(circle at 50% 45%, rgba(127, 255, 212, 0.45), transparent 60%);
  pointer-events: none;
  z-index: 60;
  animation: pulse 0.6s ease-out;
}
@keyframes pulse {
  0% {
    opacity: 0;
  }
  25% {
    opacity: 1;
  }
  100% {
    opacity: 0;
  }
}
</style>
