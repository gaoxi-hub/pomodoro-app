<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import TabBar from './TabBar.vue'
import { useToast } from '../composables/useToast'

const route = useRoute()
const toast = useToast()

const showTab = computed(() => route.meta.showTab !== false)
</script>

<template>
  <div class="app-bg">
    <div class="phone">
      <main class="screen">
        <router-view v-slot="{ Component }">
          <transition name="page" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
      <TabBar v-if="showTab" />
    </div>

    <transition name="toast">
      <div v-if="toast.visible.value" class="toast">{{ toast.message.value }}</div>
    </transition>
  </div>
</template>

<style scoped>
.app-bg {
  width: 100%;
  height: 100%;
  background: radial-gradient(circle at 50% 0%, #0a1410 0%, #000 60%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.phone {
  position: relative;
  width: 100%;
  max-width: 480px;
  height: 100dvh;
  background: #000;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

@media (min-width: 520px) {
  .phone {
    height: min(900px, 96vh);
    border-radius: 46px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.8), 0 0 60px rgba(127, 255, 212, 0.08);
  }
}

.phone::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 104px;
  background: linear-gradient(180deg, rgba(0, 0, 0, 0) 0%, #000 72%);
  pointer-events: none;
  z-index: 35;
}

.screen {
  flex: 1;
  overflow-y: auto;
  padding: 0 20px calc(96px + env(safe-area-inset-bottom));
}

.toast {
  position: fixed;
  left: 50%;
  bottom: 110px;
  transform: translateX(-50%);
  background: rgba(18, 18, 18, 0.92);
  backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: var(--text-primary);
  padding: 10px 18px;
  border-radius: var(--radius-pill);
  font-size: 14px;
  font-weight: 600;
  z-index: 200;
  box-shadow: var(--glow-soft);
  white-space: nowrap;
}
.toast-enter-active,
.toast-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(10px);
}
</style>
