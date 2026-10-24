<script setup lang="ts">
import { computed } from 'vue'
import type { PomodoroType } from '../types'

const props = defineProps<{
  progress: number // 0..1，剩余时间占比
  mode: PomodoroType
  size?: number
}>()

const size = computed(() => props.size ?? 280)
const stroke = 10
const radius = computed(() => (size.value - stroke) / 2 - 4)
const circ = computed(() => 2 * Math.PI * radius.value)
const offset = computed(() => circ.value * (1 - Math.min(1, Math.max(0, props.progress))))
const gradId = computed(
  () =>
    ({ work: 'gradWork', short: 'gradShort', long: 'gradLong' })[props.mode],
)
</script>

<template>
  <div class="hero" :style="{ width: size + 'px', height: size + 'px' }">
    <svg :width="size" :height="size" :viewBox="`0 0 ${size} ${size}`">
      <defs>
        <linearGradient id="gradWork" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#7fffd4" />
          <stop offset="100%" stop-color="#ffffff" />
        </linearGradient>
        <linearGradient id="gradShort" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#5ee0a0" />
          <stop offset="100%" stop-color="#eafff5" />
        </linearGradient>
        <linearGradient id="gradLong" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="#ff9f45" />
          <stop offset="100%" stop-color="#fff3e6" />
        </linearGradient>
      </defs>
      <circle
        class="ring-bg"
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
      />
      <circle
        class="ring-fg"
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
        :stroke="`url(#${gradId})`"
        :stroke-dasharray="circ"
        :stroke-dashoffset="offset"
      />
    </svg>
    <div class="center"><slot /></div>
  </div>
</template>

<style scoped>
.hero {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}
svg {
  position: absolute;
  inset: 0;
  transform: rotate(-90deg);
}
.ring-bg {
  fill: none;
  stroke: rgba(255, 255, 255, 0.08);
  stroke-width: 10;
}
.ring-fg {
  fill: none;
  stroke-width: 10;
  stroke-linecap: round;
  filter: drop-shadow(0 0 8px rgba(127, 255, 212, 0.6));
  transition: stroke-dashoffset 0.3s linear;
}
.center {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  z-index: 1;
}
</style>
