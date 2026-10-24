<script setup lang="ts">
import { ref } from 'vue'
import type { Task } from '../types'
import { useTasksStore } from '../stores/tasks'
import TaskCard from '../components/TaskCard.vue'
import AddTaskSheet from '../sheets/AddTaskSheet.vue'
import { useToast } from '../composables/useToast'

const tasks = useTasksStore()
const toast = useToast()

const addOpen = ref(false)
const editing = ref<Task | null>(null)

function openCreate() {
  editing.value = null
  addOpen.value = true
}
function openEdit(id: string) {
  editing.value = tasks.tasks.find((t) => t.id === id) ?? null
  addOpen.value = true
}
function onSubmit(payload: { id?: string; name: string; estimate: number }) {
  if (payload.id) {
    tasks.updateTask(payload.id, { name: payload.name, estimate: payload.estimate })
    toast.show('已保存任务')
  } else {
    tasks.addTask(payload.name, payload.estimate)
    toast.show('已创建任务')
  }
}
function onRemove(id: string) {
  if (confirm('确定删除该任务吗？此操作不可撤销。')) {
    tasks.removeTask(id)
    toast.show('已删除任务')
  }
}
function onArchive(id: string) {
  tasks.archiveTask(id)
  toast.show('🎉 任务完成！')
}
</script>

<template>
  <div class="tasks">
    <div class="topbar">
      <h1>任务</h1>
    </div>

    <div class="add-cta" @click="openCreate">＋ 添加新任务（含预估番茄数）</div>

    <div v-if="tasks.activeTasks.length === 0 && tasks.archivedTasks.length === 0" class="empty">
      还没有任务，点上方按钮创建第一个吧 🍅
    </div>

    <TaskCard
      v-for="t in tasks.activeTasks"
      :key="t.id"
      :task="t"
      @edit="openEdit"
      @remove="onRemove"
      @archive="onArchive"
    />

    <template v-if="tasks.archivedTasks.length > 0">
      <h2 class="section-title">已完成</h2>
      <TaskCard
        v-for="t in tasks.archivedTasks"
        :key="t.id"
        :task="t"
        @edit="openEdit"
        @remove="onRemove"
        @archive="onArchive"
      />
    </template>

    <AddTaskSheet
      v-model="addOpen"
      :task="editing"
      @submit="onSubmit"
      @remove="onRemove"
    />
  </div>
</template>

<style scoped>
.topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 -20px 0;
  padding: 10px 20px 12px;
  background: #000;
}
.topbar h1 {
  font-size: 30px;
  font-weight: 700;
  letter-spacing: -0.5px;
}
.add-cta {
  position: sticky;
  top: 66px;
  z-index: 19;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: #000;
  border: 1px dashed rgba(127, 255, 212, 0.4);
  border-radius: var(--radius-card);
  padding: 16px;
  margin-bottom: 18px;
  color: var(--accent);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
}
.empty {
  text-align: center;
  color: var(--text-tertiary);
  font-size: 14px;
  padding: 40px 0;
}
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-secondary);
  margin: 18px 0 12px;
}
</style>
