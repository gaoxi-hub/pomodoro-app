<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Task } from '../types'
import BottomSheet from '../components/BottomSheet.vue'
import Stepper from '../components/Stepper.vue'

const props = defineProps<{ modelValue: boolean; task?: Task | null }>()
const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  submit: [payload: { id?: string; name: string; estimate: number }]
  remove: [id: string]
}>()

const name = ref('')
const estimate = ref(3)
const isEdit = computed(() => !!props.task)

watch(
  () => props.modelValue,
  (open) => {
    if (open) {
      if (props.task) {
        name.value = props.task.name
        estimate.value = props.task.estimate
      } else {
        name.value = ''
        estimate.value = 3
      }
    }
  },
)

function submit() {
  emit('submit', {
    id: props.task?.id,
    name: name.value.trim() || '未命名任务',
    estimate: estimate.value,
  })
  emit('update:modelValue', false)
}

function remove() {
  if (props.task) emit('remove', props.task.id)
  emit('update:modelValue', false)
}
</script>

<template>
  <BottomSheet
    :model-value="props.modelValue"
    :title="isEdit ? '编辑任务' : '新建任务'"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <p class="hint">
      {{ isEdit ? '修改任务名称与预估番茄数' : '给任务起个名字，并预估需要的番茄数' }}
    </p>
    <div class="field-label">任务名称</div>
    <input
      v-model="name"
      class="name"
      type="text"
      placeholder="例如：写产品周报"
      maxlength="40"
    />
    <div class="field-label">预估番茄数</div>
    <div class="pomo-pick">
      <div class="pl">
        🍅 预计投入
        <small>1 个番茄 = 25 分钟专注</small>
      </div>
      <Stepper v-model="estimate" :min="1" :max="20" />
    </div>
    <div v-if="isEdit" class="del-row">
      <button class="del" @click="remove">删除该任务</button>
    </div>
    <div class="actions">
      <button class="btn btn-ghost" @click="emit('update:modelValue', false)">
        取消
      </button>
      <button class="btn btn-primary" @click="submit">
        {{ isEdit ? '保存' : '创建任务' }}
      </button>
    </div>
  </BottomSheet>
</template>

<style scoped>
.hint {
  font-size: 13px;
  color: var(--text-tertiary);
  margin-bottom: 18px;
}
.field-label {
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--text-tertiary);
  text-transform: uppercase;
  margin-bottom: 8px;
}
.name {
  width: 100%;
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 14px;
  padding: 14px 16px;
  color: #fff;
  font-size: 16px;
  outline: none;
  margin-bottom: 22px;
}
.name::placeholder {
  color: var(--text-tertiary);
}
.pomo-pick {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--card-bg);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
  padding: 12px 16px;
  margin-bottom: 18px;
}
.pomo-pick .pl {
  font-size: 15px;
}
.pomo-pick .pl small {
  display: block;
  font-size: 12px;
  color: var(--text-tertiary);
  margin-top: 2px;
}
.del-row {
  margin-bottom: 12px;
}
.del {
  background: transparent;
  border: none;
  color: var(--warn);
  font-size: 14px;
  font-weight: 600;
}
.actions {
  display: flex;
  gap: 12px;
}
.actions .btn {
  flex: 1;
  padding: 14px 26px;
  border-radius: var(--radius-pill);
  font-size: 15px;
  font-weight: 600;
  border: none;
}
</style>
