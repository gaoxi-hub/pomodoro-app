<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { Ref } from 'vue'
import { useStatsStore } from '../stores/stats'
import { useSettingsStore } from '../stores/settings'
import { useTasksStore } from '../stores/tasks'
import PillMetric from '../components/PillMetric.vue'
import StatChart from '../components/StatChart.vue'
import { useToast } from '../composables/useToast'

const stats = useStatsStore()
const settings = useSettingsStore()
const tasks = useTasksStore()
const toast = useToast()

const range = ref<'day' | 'week' | 'month'>('day')
const chartData = computed(() => stats.aggregate(range.value))
const fileInput = ref<HTMLInputElement | null>(null) as Ref<HTMLInputElement | null>

function triggerImport() {
  fileInput.value?.click()
}

// 专注评分（达成每日目标百分比）
const score = computed(() =>
  Math.min(
    100,
    Math.round(
      (stats.todayPomodoros / Math.max(1, settings.goal.dailyPomodoros)) * 100,
    ),
  ),
)
const displayScore = ref(0)
watch(
  score,
  (to) => {
    const from = displayScore.value
    const dur = 400
    const start = performance.now()
    const step = (now: number) => {
      const t = Math.min(1, (now - start) / dur)
      displayScore.value = Math.round(from + (to - from) * t)
      if (t < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  },
  { immediate: true },
)

const goalFilled = computed(() =>
  Math.min(stats.todayPomodoros, settings.goal.dailyPomodoros),
)

function exportData() {
  const data = {
    tasks: tasks.tasks,
    sessions: stats.sessions,
    settings: settings.settings,
    goal: settings.goal,
    exportedAt: new Date().toISOString(),
  }
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json',
  })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `pomodoro-export-${Date.now()}.json`
  a.click()
  URL.revokeObjectURL(url)
  toast.show('已导出本地数据')
}

function onImport(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  const reader = new FileReader()
  reader.onload = () => {
    try {
      const data = JSON.parse(String(reader.result))
      if (Array.isArray(data.tasks)) tasks.tasks = data.tasks
      if (Array.isArray(data.sessions)) stats.sessions = data.sessions
      if (data.settings) settings.settings = { ...settings.settings, ...data.settings }
      if (data.goal) settings.goal = { ...settings.goal, ...data.goal }
      toast.show('已导入数据')
    } catch {
      toast.show('导入失败：文件格式不正确')
    }
  }
  reader.readAsText(file)
  input.value = ''
}
</script>

<template>
  <div class="stats">
    <div class="topbar">
      <h1>统计</h1>
      <div class="top-actions">
        <button class="icon-btn" title="导入" @click="triggerImport">
          ⬇️
        </button>
        <button class="icon-btn" title="导出" @click="exportData">📤</button>
        <input ref="fileInput" type="file" accept="application/json" hidden @change="onImport" />
      </div>
    </div>

    <div class="score-hero">
      <div class="big">{{ displayScore }}</div>
      <div class="cap">专注评分 · 今日目标达成</div>
    </div>

    <div class="pills">
      <PillMetric icon="🍅" :value="stats.todayPomodoros" label="今日番茄" />
      <PillMetric
        icon="⏱️"
        :value="stats.totalPomodoros"
        label="累计番茄"
      />
      <PillMetric icon="🔥" :value="stats.streak" label="连续天数" variant="energy" />
    </div>

    <div class="seg">
      <button :class="{ active: range === 'day' }" @click="range = 'day'">日</button>
      <button :class="{ active: range === 'week' }" @click="range = 'week'">周</button>
      <button :class="{ active: range === 'month' }" @click="range = 'month'">月</button>
    </div>

    <StatChart :data="chartData" />

    <div class="goal glass">
      <div class="row">
        <span>今日番茄目标</span>
        <b>{{ stats.todayPomodoros }} / {{ settings.goal.dailyPomodoros }} 🍅</b>
      </div>
      <div class="seg-bar">
        <i
          v-for="n in settings.goal.dailyPomodoros"
          :key="n"
          :class="{ on: n <= goalFilled }"
        ></i>
      </div>
    </div>
  </div>
</template>

<style scoped>
.topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 -20px 18px;
  padding: 10px 20px 12px;
  background: #000;
}
.topbar h1 {
  font-size: 30px;
  font-weight: 700;
  letter-spacing: -0.5px;
}
.top-actions {
  display: flex;
  gap: 8px;
}
.icon-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}
.score-hero {
  text-align: center;
  margin: 6px 0 18px;
}
.big {
  font-size: 80px;
  font-weight: 700;
  line-height: 1;
  font-variant-numeric: tabular-nums;
  background: var(--accent-gradient);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  filter: drop-shadow(0 0 18px rgba(127, 255, 212, 0.4));
}
.cap {
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--text-tertiary);
  text-transform: uppercase;
}
.pills {
  display: flex;
  gap: 10px;
  margin-bottom: 22px;
}
.seg {
  display: flex;
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: var(--radius-pill);
  padding: 4px;
  margin: 0 auto 22px;
  width: fit-content;
}
.seg button {
  border: none;
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 22px;
  border-radius: var(--radius-pill);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
}
.seg button.active {
  background: rgba(127, 255, 212, 0.15);
  color: var(--accent);
}
.goal {
  padding: 16px 18px;
  margin: 18px 0;
}
.goal .row {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  margin-bottom: 10px;
}
.goal .row b {
  color: var(--accent);
}
.seg-bar {
  display: flex;
  gap: 4px;
}
.seg-bar i {
  flex: 1;
  height: 10px;
  border-radius: 3px;
  background: rgba(255, 255, 255, 0.1);
}
.seg-bar i.on {
  background: var(--accent-gradient);
  box-shadow: var(--glow-soft);
}
</style>
