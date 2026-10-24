import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import type { PomodoroSession, PomodoroType } from '../types'
import { uid } from '../composables/useStorage'
import { useSettingsStore } from './settings'
import { useTasksStore } from './tasks'
import { useStatsStore } from './stats'
import { useAchievementsStore } from './achievements'
import { useAudio } from '../composables/useAudio'
import { useNoiseMixer } from '../composables/useNoiseMixer'
import { useNotify } from '../composables/useNotify'
import { useToast } from '../composables/useToast'

let intervalId: ReturnType<typeof setInterval> | null = null

export const useTimerStore = defineStore('timer', () => {
  const settings = useSettingsStore()
  const tasks = useTasksStore()
  const stats = useStatsStore()
  const achievements = useAchievementsStore()
  const audio = useAudio()
  const noise = useNoiseMixer()
  const notify = useNotify()
  const toast = useToast()

  const mode = ref<PomodoroType>('work')
  const status = ref<'idle' | 'running' | 'paused'>('idle')
  const endAt = ref<number | null>(null)
  const remainingMs = ref<number>(settings.settings.workMin * 60000)
  const workCountInCycle = ref(0)

  // 反馈 / 提醒触发器
  const pulseTrigger = ref(0)
  const lastBreakReminder = ref(0)

  const durationMin = computed(() => {
    if (mode.value === 'work') return settings.settings.workMin
    if (mode.value === 'short') return settings.settings.shortMin
    return settings.settings.longMin
  })
  const durationMs = computed(() => durationMin.value * 60000)
  const progress = computed(() => {
    if (durationMs.value <= 0) return 0
    return Math.min(1, Math.max(0, remainingMs.value / durationMs.value))
  })
  const remainingSec = computed(() => Math.ceil(remainingMs.value / 1000))
  const isWork = computed(() => mode.value === 'work')

  function setMode(m: PomodoroType): void {
    stopTick()
    mode.value = m
    status.value = 'idle'
    endAt.value = null
    remainingMs.value = durationMs.value
    lastBreakReminder.value = Date.now()
  }

  function tick(): void {
    if (endAt.value == null) return
    const left = endAt.value - Date.now()
    remainingMs.value = Math.max(0, left)

    if (mode.value !== 'work' && settings.settings.breakEndNotify) {
      if (Date.now() >= lastBreakReminder.value + 30000) {
        lastBreakReminder.value = Date.now()
        notify.notify('起身活动', '休息一下，伸展身体～')
      }
    }

    if (left <= 0) complete()
  }

  function startTick(): void {
    stopTick()
    intervalId = setInterval(tick, 200)
  }
  function stopTick(): void {
    if (intervalId != null) {
      clearInterval(intervalId)
      intervalId = null
    }
  }

  function start(): void {
    notify.request()
    if (status.value === 'running') return
    if (status.value === 'idle') remainingMs.value = durationMs.value
    endAt.value = Date.now() + remainingMs.value
    status.value = 'running'
    startTick()
    if (mode.value === 'work') noise.sync(settings.settings.noise)
  }

  function pause(): void {
    if (status.value !== 'running') return
    stopTick()
    noise.stopAll()
    status.value = 'paused'
  }

  function reset(): void {
    stopTick()
    noise.stopAll()
    status.value = 'idle'
    endAt.value = null
    remainingMs.value = durationMs.value
  }

  function makeSession(completed: boolean): PomodoroSession {
    const started =
      endAt.value != null ? endAt.value - durationMs.value : Date.now() - durationMs.value
    return {
      id: uid(),
      taskId: tasks.currentTaskId,
      type: mode.value,
      startedAt: started,
      endedAt: Date.now(),
      plannedMin: durationMin.value,
      completed,
    }
  }

  function complete(): void {
    stopTick()
    noise.stopAll()
    const session = makeSession(true)

    if (mode.value === 'work') {
      stats.addSession(session)
      if (tasks.currentTaskId) tasks.incrementDone(tasks.currentTaskId)
      if (settings.settings.soundOn) audio.ding()
      if (settings.settings.celebrate) pulseTrigger.value++
      if (typeof navigator !== 'undefined' && navigator.vibrate) navigator.vibrate(40)
      notify.notify('专注完成 🍅', '干得漂亮，该休息一下了')
      toast.show('🍅 完成一个番茄！')
      achievements.evaluate()
      workCountInCycle.value++
      const next: PomodoroType =
        workCountInCycle.value % settings.settings.longBreakInterval === 0
          ? 'long'
          : 'short'
      setMode(next)
    } else {
      if (settings.settings.breakEndNotify)
        notify.notify('休息结束', '回来继续专注吧 ⏳')
      stats.addSession(session)
      setMode('work')
    }

    if (settings.settings.autoStartNext) {
      start()
    } else {
      status.value = 'idle'
      endAt.value = null
    }
  }

  function skip(): void {
    stopTick()
    noise.stopAll()
    if (mode.value === 'work') {
      stats.addSession(makeSession(false))
      workCountInCycle.value++
    }
    const next: PomodoroType =
      mode.value === 'work'
        ? workCountInCycle.value % settings.settings.longBreakInterval === 0
          ? 'long'
          : 'short'
        : 'work'
    setMode(next)
    if (settings.settings.autoStartNext) start()
  }

  watch(
    () => [settings.settings.workMin, settings.settings.shortMin, settings.settings.longMin],
    () => {
      if (status.value === 'idle') remainingMs.value = durationMs.value
    },
  )

  return {
    mode,
    status,
    remainingMs,
    remainingSec,
    progress,
    isWork,
    workCountInCycle,
    pulseTrigger,
    setMode,
    start,
    pause,
    reset,
    complete,
    skip,
  }
})
