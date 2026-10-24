<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{ done: number; estimate: number }>()
const pct = computed(() => {
  if (props.estimate <= 0) return 0
  return Math.min(1, props.done / props.estimate) * 100
})
const full = computed(() => props.estimate > 0 && props.done >= props.estimate)
</script>

<template>
  <div class="bar">
    <i :class="{ full }" :style="{ width: pct + '%' }"></i>
  </div>
</template>

<style scoped>
.bar {
  height: 8px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.08);
  overflow: hidden;
}
.bar > i {
  display: block;
  height: 100%;
  background: var(--accent-gradient);
  box-shadow: var(--glow-soft);
  border-radius: 4px;
  transition: width 0.4s ease;
}
.bar > i.full {
  background: var(--accent-gradient);
}
</style>
