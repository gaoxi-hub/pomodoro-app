import { defineStore } from 'pinia'
import { ref, watch } from 'vue'
import { loadJSON, saveJSON } from '../composables/useStorage'
import { NOISE_SOUNDS } from '../types'
import type { Goal, NoiseConfig, NoiseLayer, NoiseSound, Settings } from '../types'

const DEFAULT_NOISE: NoiseConfig = {
  master: 0.6,
  layers: Object.fromEntries(
    NOISE_SOUNDS.map((s) => [s.key, { on: false, volume: 0.5 }]),
  ) as Record<NoiseSound, NoiseLayer>,
}

const DEFAULT_SETTINGS: Settings = {
  workMin: 25,
  shortMin: 5,
  longMin: 15,
  longBreakInterval: 4,
  autoStartNext: true,
  breakEndNotify: true,
  celebrate: true,
  soundOn: true,
  noise: DEFAULT_NOISE,
}

const DEFAULT_GOAL: Goal = { dailyPomodoros: 8 }

export const useSettingsStore = defineStore('settings', () => {
  const settings = ref<Settings>({
    ...DEFAULT_SETTINGS,
    ...loadJSON<Partial<Settings>>('settings', {}),
  })
  const goal = ref<Goal>({
    ...DEFAULT_GOAL,
    ...loadJSON<Partial<Goal>>('goal', {}),
  })

  watch(settings, () => saveJSON('settings', settings.value), { deep: true })
  watch(goal, () => saveJSON('goal', goal.value), { deep: true })

  function update(patch: Partial<Settings>): void {
    settings.value = { ...settings.value, ...patch }
  }

  function updateGoal(dailyPomodoros: number): void {
    goal.value.dailyPomodoros = Math.max(1, Math.min(30, Math.floor(dailyPomodoros)))
  }

  return { settings, goal, update, updateGoal }
})
