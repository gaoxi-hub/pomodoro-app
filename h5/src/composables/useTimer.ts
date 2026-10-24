import { useTimerStore } from '../stores/timer'

/**
 * 计时引擎访问器。
 * 计时逻辑（基于时间戳精确计时，禁止 setInterval 累加秒数）统一实现于
 * `stores/timer.ts` 的单例 store 中；本 composable 仅作为组件侧的便捷入口，
 * 保证全局只有一个计时状态源。
 */
export function useTimer() {
  return useTimerStore()
}
