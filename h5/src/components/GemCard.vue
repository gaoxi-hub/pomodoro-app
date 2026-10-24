<script setup lang="ts">
import type { AchievementView } from '../types'
defineProps<{ gem: AchievementView }>()
</script>

<template>
  <div class="gem" :class="[gem.variant === 'energy' ? 'energy' : '', !gem.unlocked ? 'locked' : '']">
    <div class="orb"></div>
    <div class="gname">{{ gem.name }}</div>
    <div class="gsub">{{ gem.unlocked ? gem.desc : '未解锁' }}</div>
  </div>
</template>

<style scoped>
.gem {
  flex: 0 0 110px;
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: var(--radius-card);
  padding: 16px;
  text-align: center;
}
.orb {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  margin: 0 auto 10px;
  background: radial-gradient(circle at 35% 30%, #fff, var(--accent) 60%, #1c5f4d);
  box-shadow: 0 0 22px rgba(127, 255, 212, 0.5);
}
.energy .orb {
  background: radial-gradient(circle at 35% 30%, #fff, var(--energy) 60%, #7a4a14);
  box-shadow: 0 0 22px rgba(255, 159, 69, 0.5);
}
.locked .orb {
  opacity: 0.3;
  box-shadow: none;
}
.gname {
  font-size: 13px;
  font-weight: 600;
}
.gsub {
  font-size: 10px;
  color: var(--text-tertiary);
  margin-top: 3px;
}
</style>
