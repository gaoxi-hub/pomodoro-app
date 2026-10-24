let ctx: AudioContext | null = null

/** 获取（并在需要时唤醒）全局 AudioContext。无 Web Audio 时返回 null。 */
export function getCtx(): AudioContext | null {
  if (typeof window === 'undefined') return null
  const AC =
    window.AudioContext ||
    (window as unknown as { webkitAudioContext?: typeof AudioContext })
      .webkitAudioContext
  if (!AC) return null
  if (!ctx) ctx = new AC()
  if (ctx.state === 'suspended') void ctx.resume()
  return ctx
}

/** 番茄完成提示音：两声清脆"叮" */
export function ding(): void {
  const c = getCtx()
  if (!c) return
  const now = c.currentTime
  const notes = [880, 1320]
  notes.forEach((freq, i) => {
    const osc = c.createOscillator()
    const gain = c.createGain()
    osc.type = 'sine'
    osc.frequency.value = freq
    const t = now + i * 0.12
    gain.gain.setValueAtTime(0.0001, t)
    gain.gain.exponentialRampToValueAtTime(0.3, t + 0.02)
    gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.5)
    osc.connect(gain)
    gain.connect(c.destination)
    osc.start(t)
    osc.stop(t + 0.55)
  })
}

/** 番茄完成提示音等音效的统一入口 */
export function useAudio() {
  return { ding }
}
