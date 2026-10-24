<script setup lang="ts">
import type { Task } from '../types'
import PomodoroBar from './PomodoroBar.vue'

const props = defineProps<{ task: Task }>()
const emit = defineEmits<{
  edit: [id: string]
  remove: [id: string]
  archive: [id: string]
}>()

const pct = () =>
  props.task.estimate > 0
    ? Math.round((props.task.done / props.task.estimate) * 100)
    : 0
const canComplete = () =>
  !props.task.archived && props.task.done >= props.task.estimate
</script>

<template>
  <div class="task-card" :class="{ done: props.task.archived }">
    <div class="head">
      <div class="tname">{{ props.task.name }}</div>
      <div class="pomo">
        <b>{{ props.task.done }}</b> / {{ props.task.estimate }} 🍅
      </div>
    </div>
    <PomodoroBar :done="props.task.done" :estimate="props.task.estimate" />
    <div class="meta">
      <span class="pct">{{ pct() }}%</span>
      <div class="acts">
        <button
          v-if="canComplete()"
          class="act ok"
          @click="emit('archive', props.task.id)"
        >
          完成
        </button>
        <button class="act" @click="emit('edit', props.task.id)">编辑</button>
        <button class="act danger" @click="emit('remove', props.task.id)">
          删除
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.task-card {
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: var(--radius-card);
  padding: 16px 18px;
  margin-bottom: 12px;
}
.task-card.done {
  opacity: 0.6;
}
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.tname {
  font-size: 17px;
  font-weight: 600;
}
.pomo {
  font-size: 13px;
  color: var(--text-secondary);
}
.pomo b {
  color: var(--accent);
  font-size: 15px;
}
.meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}
.pct {
  font-size: 12px;
  color: var(--text-tertiary);
  font-variant-numeric: tabular-nums;
}
.acts {
  display: flex;
  gap: 8px;
}
.act {
  background: transparent;
  border: 1px solid rgba(255, 255, 255, 0.18);
  color: var(--text-secondary);
  border-radius: var(--radius-pill);
  padding: 6px 12px;
  font-size: 12px;
  font-weight: 600;
}
.act.ok {
  border-color: var(--accent);
  color: var(--accent);
}
.act.danger {
  border-color: transparent;
  color: var(--warn);
}
</style>
