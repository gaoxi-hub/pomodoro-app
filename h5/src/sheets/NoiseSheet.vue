<script setup lang="ts">
import { watch } from 'vue'
import { useSettingsStore } from '../stores/settings'
import { useNoiseMixer } from '../composables/useNoiseMixer'
import { NOISE_SOUNDS } from '../types'
import type { NoiseSound } from '../types'
import BottomSheet from '../components/BottomSheet.vue'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{ 'update:modelValue': [value: boolean] }>()

const store = useSettingsStore()
const noise = useNoiseMixer()
const sounds = NOISE_SOUNDS

function close() {
  emit('update:modelValue', false)
}

function toggle(key: NoiseSound) {
  const layer = store.settings.noise.layers[key]
  layer.on = !layer.on
  noise.sync(store.settings.noise)
}

function setMaster(e: Event) {
  store.settings.noise.master = parseFloat((e.target as HTMLInputElement).value)
  noise.sync(store.settings.noise)
}

function setVol(key: NoiseSound, e: Event) {
  store.settings.noise.layers[key].volume = parseFloat((e.target as HTMLInputElement).value)
  noise.sync(store.settings.noise)
}

function stopAll() {
  for (const k of Object.keys(store.settings.noise.layers) as NoiseSound[]) {
    store.settings.noise.layers[k].on = false
  }
  noise.stopAll()
}

// 打开面板（用户点击=手势）时唤醒音频并应用已保存配置
watch(
  () => props.modelValue,
  (v) => {
    if (v) noise.sync(store.settings.noise)
  },
)
</script>

<template>
  <BottomSheet :model-value="props.modelValue" title="环境音" @update:model-value="close">
    <p class="lead">可同时开启多种声音，分别调节音量，像白噪音一样叠加播放。</p>

    <div class="master">
      <span class="ml">🔊 总音量</span>
      <input
        class="slider"
        type="range"
        min="0"
        max="1"
        step="0.01"
        :value="store.settings.noise.master"
        @input="setMaster"
      />
    </div>

    <div class="rows">
      <div
        v-for="s in sounds"
        :key="s.key"
        class="row"
        :class="{ on: store.settings.noise.layers[s.key].on }"
      >
        <button class="toggle" @click="toggle(s.key)">
          <span class="ic">{{ s.icon }}</span>
          <span class="nm">{{ s.label }}</span>
          <span class="dot"></span>
        </button>
        <input
          class="slider"
          type="range"
          min="0"
          max="1"
          step="0.01"
          :value="store.settings.noise.layers[s.key].volume"
          :disabled="!store.settings.noise.layers[s.key].on"
          @input="setVol(s.key, $event)"
        />
      </div>
    </div>

    <button class="clear" @click="stopAll">全部静音</button>
  </BottomSheet>
</template>

<style scoped>
.lead {
  font-size: 13px;
  color: var(--text-tertiary);
  margin: -2px 0 16px;
  line-height: 1.5;
}
.master {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 18px;
}
.master .ml {
  font-size: 14px;
  font-weight: 600;
  flex: 0 0 auto;
}
.rows {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 46vh;
  overflow-y: auto;
  padding-right: 4px;
  scrollbar-width: thin;
}
.row {
  display: flex;
  align-items: center;
  gap: 14px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.07);
  border-radius: 16px;
  padding: 10px 14px;
  transition: 0.2s;
}
.row.on {
  background: rgba(127, 255, 212, 0.08);
  border-color: rgba(127, 255, 212, 0.35);
}
.toggle {
  display: flex;
  align-items: center;
  gap: 8px;
  background: transparent;
  border: none;
  color: var(--text-secondary);
  flex: 0 0 116px;
  min-width: 0;
  text-align: left;
}
.row.on .toggle {
  color: var(--accent);
}
.toggle .ic {
  font-size: 20px;
}
.toggle .nm {
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
}
.toggle .dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  margin-left: auto;
}
.row.on .toggle .dot {
  background: var(--accent);
  box-shadow: var(--glow-soft);
}
.slider {
  flex: 1;
  max-width: 150px;
  -webkit-appearance: none;
  appearance: none;
  height: 4px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.18);
  outline: none;
}
.slider:disabled {
  opacity: 0.35;
}
.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: var(--glow-soft);
  cursor: pointer;
}
.slider::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border: none;
  border-radius: 50%;
  background: var(--accent);
  box-shadow: var(--glow-soft);
  cursor: pointer;
}
.clear {
  width: 100%;
  margin-top: 18px;
  padding: 12px;
  border-radius: var(--radius-pill);
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 600;
}
</style>
