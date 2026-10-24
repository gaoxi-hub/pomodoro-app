import { getCtx } from './useAudio'
import { NOISE_SOUNDS } from '../types'
import type { NoiseConfig, NoiseSound } from '../types'

/**
 * 多音轨环境音混音引擎（参考 asoftmurmur.com）。
 * - 每个音轨播放 public/audio/ 下的真实录音（ogg），可同时叠加；
 * - 每轨独立音量 + 总音量；
 * - 末端接 DynamicsCompressor，避免多轨叠加时削波刺耳。
 * 全部为模块级单例，跨组件共享同一套音频图。
 *
 * 注意：ogg 在 Safari / iOS 原生不支持，iOS 设备需转 mp3/m4a 才能播放。
 */

let masterGain: GainNode | null = null
let comp: DynamicsCompressorNode | null = null

interface ActiveLayer {
  el: HTMLAudioElement
  gain: GainNode
}
const active = new Map<NoiseSound, ActiveLayer>()

function ensureMaster(c: AudioContext): void {
  if (masterGain && comp) return
  masterGain = c.createGain()
  comp = c.createDynamicsCompressor()
  comp.threshold.value = -12
  comp.knee.value = 24
  comp.ratio.value = 4
  comp.attack.value = 0.004
  comp.release.value = 0.25
  masterGain.connect(comp)
  comp.connect(c.destination)
}

function ensureLayer(key: NoiseSound, c: AudioContext): ActiveLayer {
  const existing = active.get(key)
  if (existing) return existing
  const meta = NOISE_SOUNDS.find((s) => s.key === key)
  if (!meta) throw new Error(`unknown noise sound: ${key}`)
  const el = new Audio(`${import.meta.env.BASE_URL}audio/${meta.file}`)
  el.loop = true
  el.preload = 'auto'
  const src = c.createMediaElementSource(el)
  const gain = c.createGain()
  src.connect(gain)
  gain.connect(masterGain!)
  const layer: ActiveLayer = { el, gain }
  active.set(key, layer)
  return layer
}

export function useNoiseMixer() {
  /** 将音频图同步到配置：开启/关闭各轨、设置每轨与总音量 */
  function sync(cfg: NoiseConfig): void {
    const c = getCtx()
    if (!c) return
    ensureMaster(c)
    if (masterGain) masterGain.gain.value = cfg.master
    for (const s of NOISE_SOUNDS) {
      const layer = cfg.layers[s.key]
      const node = active.get(s.key)
      if (layer.on) {
        const n = ensureLayer(s.key, c)
        n.gain.gain.value = layer.volume
        if (n.el.paused) void n.el.play().catch(() => {})
      } else if (node) {
        node.el.pause()
        node.gain.gain.value = 0
      }
    }
  }

  /** 立即停止全部音轨（如退出时清理） */
  function stopAll(): void {
    for (const node of active.values()) {
      node.el.pause()
      node.gain.gain.value = 0
    }
  }

  /** 是否有任意音轨开启 */
  function anyOn(cfg: NoiseConfig): boolean {
    return Object.values(cfg.layers).some((l) => l.on)
  }

  return { sync, stopAll, anyOn }
}
