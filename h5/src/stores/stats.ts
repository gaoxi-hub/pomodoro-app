import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { loadJSON, saveJSON } from '../composables/useStorage'
import type { ChartPoint, PomodoroSession } from '../types'

function dayKey(ts: number): string {
  const d = new Date(ts)
  d.setHours(0, 0, 0, 0)
  return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
}

export const useStatsStore = defineStore('stats', () => {
  const sessions = ref<PomodoroSession[]>(
    loadJSON<PomodoroSession[]>('sessions', []),
  )

  watch(sessions, () => saveJSON('sessions', sessions.value), { deep: true })

  const completedWork = computed(() =>
    sessions.value.filter((s) => s.type === 'work' && s.completed),
  )

  const todayPomodoros = computed(
    () =>
      completedWork.value.filter((s) => dayKey(s.endedAt) === dayKey(Date.now()))
        .length,
  )

  const todayFocusMinutes = computed(
    () =>
      completedWork.value
        .filter((s) => dayKey(s.endedAt) === dayKey(Date.now()))
        .reduce((acc, s) => acc + s.plannedMin, 0),
  )

  const totalPomodoros = computed(() => completedWork.value.length)

  const maxDayPomodoros = computed(() => {
    const map = new Map<string, number>()
    for (const s of completedWork.value) {
      const k = dayKey(s.endedAt)
      map.set(k, (map.get(k) ?? 0) + 1)
    }
    let max = 0
    for (const v of map.values()) max = Math.max(max, v)
    return max
  })

  /** 连续天数：含今日/昨日向前连续有 >=1 完成工作 session 的天数 */
  const streak = computed(() => {
    const days = new Set(completedWork.value.map((s) => dayKey(s.endedAt)))
    const d = new Date()
    d.setHours(0, 0, 0, 0)
    if (!days.has(dayKey(d.getTime()))) {
      d.setDate(d.getDate() - 1)
      if (!days.has(dayKey(d.getTime()))) return 0
    }
    let count = 0
    while (days.has(dayKey(d.getTime()))) {
      count += 1
      d.setDate(d.getDate() - 1)
    }
    return count
  })

  function addSession(s: PomodoroSession): void {
    sessions.value.push(s)
  }

  function aggregate(range: 'day' | 'week' | 'month'): ChartPoint[] {
    const result: ChartPoint[] = []
    const now = new Date()
    now.setHours(0, 0, 0, 0)

    if (range === 'day') {
      const wd = ['日', '一', '二', '三', '四', '五', '六']
      for (let i = 6; i >= 0; i--) {
        const d = new Date(now)
        d.setDate(d.getDate() - i)
        const key = dayKey(d.getTime())
        const val = completedWork.value.filter(
          (s) => dayKey(s.endedAt) === key,
        ).length
        result.push({ label: wd[d.getDay()], value: val })
      }
    } else if (range === 'week') {
      const startOfWeek = (offsetWeeks: number) => {
        const d = new Date(now)
        d.setDate(d.getDate() - d.getDay() - offsetWeeks * 7)
        return d
      }
      for (let i = 7; i >= 0; i--) {
        const start = startOfWeek(i)
        const end = new Date(start)
        end.setDate(start.getDate() + 7)
        const val = completedWork.value.filter(
          (s) => s.endedAt >= start.getTime() && s.endedAt < end.getTime(),
        ).length
        result.push({
          label: `${start.getMonth() + 1}/${start.getDate()}`,
          value: val,
        })
      }
    } else {
      for (let i = 11; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
        const y = d.getFullYear()
        const m = d.getMonth()
        const val = completedWork.value.filter((s) => {
          const sd = new Date(s.endedAt)
          return sd.getFullYear() === y && sd.getMonth() === m
        }).length
        result.push({ label: `${m + 1}月`, value: val })
      }
    }
    return result
  }

  return {
    sessions,
    todayPomodoros,
    todayFocusMinutes,
    totalPomodoros,
    maxDayPomodoros,
    streak,
    addSession,
    aggregate,
  }
})
