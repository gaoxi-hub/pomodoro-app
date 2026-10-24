<script setup lang="ts">
import { computed } from 'vue'
import type { ChartPoint } from '../types'

const props = defineProps<{ data: ChartPoint[] }>()

const max = computed(() =>
  Math.max(1, ...props.data.map((d) => d.value)),
)

function height(value: number): string {
  if (value <= 0) return '2px'
  return (value / max.value) * 100 + '%'
}
</script>

<template>
  <div class="chart">
    <div v-for="(p, i) in props.data" :key="i" class="col">
      <span class="v" v-if="p.value > 0">{{ p.value }}</span>
      <div class="b" :style="{ height: height(p.value) }"></div>
      <div class="d">{{ p.label }}</div>
    </div>
  </div>
</template>

<style scoped>
.chart {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  height: 160px;
  padding: 0 4px;
}
.col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
  height: 100%;
}
.v {
  font-size: 11px;
  color: var(--text-secondary);
  font-variant-numeric: tabular-nums;
}
.b {
  width: 100%;
  border-radius: 6px 6px 0 0;
  background: linear-gradient(180deg, var(--accent), rgba(127, 255, 212, 0.15));
  box-shadow: var(--glow-soft);
  min-height: 2px;
  transition: height 0.4s ease;
}
.d {
  font-size: 10px;
  color: var(--text-tertiary);
}
</style>
