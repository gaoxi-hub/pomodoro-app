<script setup lang="ts">
import BottomSheet from '../components/BottomSheet.vue'
import { useTasksStore } from '../stores/tasks'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  pick: [id: string | null]
}>()

const tasks = useTasksStore()

function pick(id: string | null) {
  emit('pick', id)
  emit('update:modelValue', false)
}
</script>

<template>
  <BottomSheet
    :model-value="props.modelValue"
    title="选择专注任务"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <p class="hint">选择后将在主页计时器绑定该任务</p>
    <div class="pick-list">
      <div
        v-for="t in tasks.activeTasks"
        :key="t.id"
        class="pick-item"
        :class="{ active: tasks.currentTaskId === t.id }"
        @click="pick(t.id)"
      >
        <div>
          <div class="pi-name">{{ t.name }}</div>
          <div class="pi-sub">
            已投入 {{ t.done }} / 预估 {{ t.estimate }} 🍅
          </div>
        </div>
        <div class="check">
          {{ tasks.currentTaskId === t.id ? '✓' : '' }}
        </div>
      </div>
      <div v-if="tasks.activeTasks.length === 0" class="empty">
        还没有任务，先去「任务」页创建一个吧
      </div>
      <div class="pick-item none" @click="pick(null)">
        <div class="pi-name">不绑定任务</div>
        <div class="pi-sub">仅计时，不计入任何任务</div>
        <div class="check">{{ tasks.currentTaskId === null ? '✓' : '' }}</div>
      </div>
    </div>
  </BottomSheet>
</template>

<style scoped>
.hint {
  font-size: 13px;
  color: var(--text-tertiary);
  margin-bottom: 18px;
}
.pick-list {
  max-height: 50vh;
  overflow-y: auto;
}
.pick-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 16px;
  margin-bottom: 10px;
  cursor: pointer;
}
.pick-item.active {
  border-color: var(--accent);
  box-shadow: var(--glow-soft);
}
.pi-name {
  font-size: 16px;
  font-weight: 600;
}
.pi-sub {
  font-size: 12px;
  color: var(--text-secondary);
  margin-top: 3px;
}
.check {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 1.5px solid rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  flex: 0 0 auto;
}
.pick-item.active .check {
  background: var(--accent);
  border-color: var(--accent);
  color: #04201a;
}
.empty {
  font-size: 13px;
  color: var(--text-tertiary);
  text-align: center;
  padding: 16px;
}
</style>
