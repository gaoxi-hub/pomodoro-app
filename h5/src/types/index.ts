export type PomodoroType = 'work' | 'short' | 'long'

/**
 * 环境音轨元数据（单一来源：key → 文件 / 图标 / 名称）。
 * 音频文件存放于 public/audio/，以 `${import.meta.env.BASE_URL}audio/<file>` 引用（自动适配 GitHub Pages 子路径）。
 */
export const NOISE_SOUNDS = [
  { key: 'cat', file: 'cat-purring.ogg', icon: '🐱', label: '猫咪呼噜' },
  { key: 'crickets', file: 'crickets.ogg', icon: '🦗', label: '虫鸣' },
  { key: 'seagulls', file: 'seagulls.ogg', icon: '🕊️', label: '海鸥' },
  { key: 'campfire', file: 'campfire.ogg', icon: '🔥', label: '篝火' },
  { key: 'lake', file: 'lake.ogg', icon: '🏞️', label: '湖泊' },
  { key: 'river', file: 'river.ogg', icon: '💧', label: '河流' },
  { key: 'wind', file: 'wind.ogg', icon: '🍃', label: '风声' },
  { key: 'piano', file: 'piano.ogg', icon: '🎹', label: '钢琴' },
  { key: 'rainwind', file: '小雨加风.ogg', icon: '🌧️', label: '小雨加风' },
  { key: 'drizzle', file: 'drizzle.ogg', icon: '🌦️', label: '细雨' },
  { key: 'thunder', file: 'thunderstorm.ogg', icon: '⛈️', label: '雷暴' },
  { key: 'bowl', file: 'singing-bowl.ogg', icon: '🔔', label: '颂钵' },
  { key: 'train', file: 'inside-a-train.ogg', icon: '🚂', label: '火车内' },
  { key: 'airplane', file: 'airplane.ogg', icon: '✈️', label: '飞机' },
] as const

export type NoiseSound = (typeof NOISE_SOUNDS)[number]['key']

export interface NoiseLayer {
  on: boolean
  volume: number // 0..1
}

export interface NoiseConfig {
  master: number // 0..1 总音量
  layers: Record<NoiseSound, NoiseLayer>
}

export interface Task {
  id: string
  name: string
  estimate: number // >= 1
  done: number
  createdAt: number // epoch ms
  archived?: boolean
}

export interface PomodoroSession {
  id: string
  taskId: string | null
  type: PomodoroType
  startedAt: number
  endedAt: number
  plannedMin: number
  completed: boolean
}

export interface Settings {
  workMin: number
  shortMin: number
  longMin: number
  longBreakInterval: number
  autoStartNext: boolean
  breakEndNotify: boolean
  celebrate: boolean
  soundOn: boolean
  noise: NoiseConfig
}

export interface Goal {
  dailyPomodoros: number
}

export interface ChartPoint {
  label: string
  value: number
}

export interface AchievementDef {
  id: string
  name: string
  desc: string
  variant: 'accent' | 'energy'
  rule: (streak: number, total: number, maxDay: number) => boolean
}

export interface AchievementView extends AchievementDef {
  unlocked: boolean
}
