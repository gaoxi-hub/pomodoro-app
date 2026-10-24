<script setup lang="ts">
defineProps<{
  icon: string
  value: string | number
  label: string
  variant?: 'accent' | 'energy'
}>()
</script>

<template>
  <div class="pill" :class="variant === 'energy' ? 'energy' : ''">
    <div class="ico">{{ icon }}</div>
    <div class="num">{{ value }}</div>
    <div class="cap">{{ label }}</div>
  </div>
</template>

<style scoped>
.pill {
  flex: 1;
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 18px;
  padding: 14px 6px;
  text-align: center;
  position: relative;
}
.ico {
  font-size: 18px;
  margin-bottom: 4px;
}
.num {
  font-size: 22px;
  font-weight: 700;
  color: var(--accent);
  font-variant-numeric: tabular-nums;
}
.energy .num {
  color: var(--energy);
}
.cap {
  font-size: 10px;
  letter-spacing: 1px;
  color: var(--text-tertiary);
  text-transform: uppercase;
  margin-top: 2px;
}
</style>
