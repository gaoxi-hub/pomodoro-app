import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { loadJSON, saveJSON } from '../composables/useStorage'
import type { AchievementDef, AchievementView } from '../types'
import { useStatsStore } from './stats'
import { useToast } from '../composables/useToast'

export const ACHIEVEMENTS: AchievementDef[] = [
  {
    id: 'first',
    name: '首胜',
    desc: '连续 7 天专注',
    variant: 'accent',
    rule: (streak) => streak >= 7,
  },
  {
    id: 'ten',
    name: '十连击',
    desc: '单日 10 个番茄',
    variant: 'energy',
    rule: (_s, _t, maxDay) => maxDay >= 10,
  },
  {
    id: 'hundred',
    name: '百番茄',
    desc: '累计 100 个番茄',
    variant: 'accent',
    rule: (_s, total) => total >= 100,
  },
  {
    id: 'streak30',
    name: '月度恒星',
    desc: '连续 30 天专注',
    variant: 'energy',
    rule: (streak) => streak >= 30,
  },
  {
    id: 'goal',
    name: '达标者',
    desc: '单日达成目标',
    variant: 'accent',
    rule: (streak, _t, maxDay) => maxDay >= 8,
  },
]

export const useAchievementsStore = defineStore('achievements', () => {
  const unlocked = ref<string[]>(loadJSON<string[]>('achievements', []))
  const stats = useStatsStore()
  const toast = useToast()

  watch(unlocked, () => saveJSON('achievements', unlocked.value), { deep: true })

  function evaluate(): void {
    const streak = stats.streak
    const total = stats.totalPomodoros
    const maxDay = stats.maxDayPomodoros
    for (const a of ACHIEVEMENTS) {
      if (!unlocked.value.includes(a.id) && a.rule(streak, total, maxDay)) {
        unlocked.value.push(a.id)
        toast.show(`💎 成就解锁：${a.name}`)
      }
    }
  }

  const list = computed<AchievementView[]>(() =>
    ACHIEVEMENTS.map((a) => ({ ...a, unlocked: unlocked.value.includes(a.id) })),
  )

  const unlockedCount = computed(() => unlocked.value.length)

  return { unlocked, evaluate, list, unlockedCount }
})
