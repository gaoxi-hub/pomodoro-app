import { defineStore } from 'pinia'
import { ref, computed, watch } from 'vue'
import { loadJSON, saveJSON, uid } from '../composables/useStorage'
import type { Task } from '../types'

export const useTasksStore = defineStore('tasks', () => {
  const tasks = ref<Task[]>(loadJSON<Task[]>('tasks', []))
  const currentTaskId = ref<string | null>(
    loadJSON<string | null>('currentTaskId', null),
  )

  watch(
    tasks,
    (list) => {
      if (currentTaskId.value && !list.some((t) => t.id === currentTaskId.value)) {
        currentTaskId.value = null
      }
    },
    { deep: true },
  )

  watch(
    [tasks, currentTaskId],
    () => {
      saveJSON('tasks', tasks.value)
      saveJSON('currentTaskId', currentTaskId.value)
    },
    { deep: true },
  )

  const currentTask = computed(
    () => tasks.value.find((t) => t.id === currentTaskId.value) ?? null,
  )
  const activeTasks = computed(() =>
    tasks.value.filter((t) => !t.archived),
  )
  const archivedTasks = computed(() =>
    tasks.value.filter((t) => t.archived),
  )

  function addTask(name: string, estimate: number): Task {
    const task: Task = {
      id: uid(),
      name: name.trim() || '未命名任务',
      estimate: Math.max(1, Math.min(20, Math.floor(estimate))),
      done: 0,
      createdAt: Date.now(),
    }
    tasks.value.unshift(task)
    return task
  }

  function updateTask(id: string, patch: Partial<Omit<Task, 'id'>>): void {
    const t = tasks.value.find((x) => x.id === id)
    if (!t) return
    Object.assign(t, patch)
    if (typeof patch.estimate === 'number') {
      t.estimate = Math.max(1, Math.min(20, Math.floor(patch.estimate)))
    }
  }

  function removeTask(id: string): void {
    tasks.value = tasks.value.filter((t) => t.id !== id)
    if (currentTaskId.value === id) currentTaskId.value = null
  }

  function archiveTask(id: string): void {
    const t = tasks.value.find((x) => x.id === id)
    if (!t) return
    t.archived = true
    if (currentTaskId.value === id) currentTaskId.value = null
  }

  function setCurrentTask(id: string | null): void {
    currentTaskId.value = id
  }

  function incrementDone(id: string): void {
    const t = tasks.value.find((x) => x.id === id)
    if (!t) return
    t.done += 1
  }

  return {
    tasks,
    currentTaskId,
    currentTask,
    activeTasks,
    archivedTasks,
    addTask,
    updateTask,
    removeTask,
    archiveTask,
    setCurrentTask,
    incrementDone,
  }
})
