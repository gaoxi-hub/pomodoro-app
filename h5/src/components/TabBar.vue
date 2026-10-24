<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const tabs = [
  { path: '/', icon: '⏳', label: '主页' },
  { path: '/tasks', icon: '✓', label: '任务' },
  { path: '/stats', icon: '📊', label: '统计' },
]

function isActive(path: string): boolean {
  return route.path === path
}
function go(path: string) {
  if (route.path !== path) router.push(path)
}
</script>

<template>
  <nav class="tabbar">
    <button
      v-for="t in tabs"
      :key="t.path"
      class="tab"
      :class="{ active: isActive(t.path) }"
      @click="go(t.path)"
    >
      <span class="tab-inner">
        <span class="ti">{{ t.icon }}</span>
        <span class="tl">{{ t.label }}</span>
      </span>
    </button>
  </nav>
</template>

<style scoped>
.tabbar {
  position: absolute;
  bottom: calc(18px + env(safe-area-inset-bottom));
  left: 50%;
  transform: translateX(-50%);
  width: calc(100% - 48px);
  max-width: 360px;
  height: 66px;
  background: rgba(16, 16, 16, 0.78);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 24px;
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.55), inset 0 1px 0 rgba(255, 255, 255, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 0 6px;
  z-index: 40;
}
.tab {
  flex: 1;
  display: flex;
  justify-content: center;
  background: transparent;
  border: none;
  color: var(--text-secondary);
}
.tab-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 9px 18px;
  border-radius: 18px;
  font-size: 10px;
  transition: background 0.25s ease, box-shadow 0.25s ease;
}
.tab .ti {
  font-size: 20px;
  line-height: 1;
}
.tab.active .tab-inner {
  background: rgba(127, 255, 212, 0.14);
  box-shadow: 0 0 20px rgba(127, 255, 212, 0.28);
}
.tab.active .ti {
  filter: drop-shadow(0 0 8px rgba(127, 255, 212, 0.85));
}
.tab.active .tl {
  color: var(--accent);
  font-weight: 700;
}
</style>
