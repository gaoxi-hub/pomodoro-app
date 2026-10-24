<script setup lang="ts">
const props = defineProps<{
  modelValue: number
  min?: number
  max?: number
  step?: number
}>()
const emit = defineEmits<{ 'update:modelValue': [value: number] }>()

const min = props.min ?? 1
const max = props.max ?? 20
const step = props.step ?? 1

function dec() {
  emit('update:modelValue', Math.max(min, props.modelValue - step))
}
function inc() {
  emit('update:modelValue', Math.min(max, props.modelValue + step))
}
</script>

<template>
  <div class="stepper">
    <button :disabled="props.modelValue <= min" @click="dec">−</button>
    <span class="val">{{ props.modelValue }}</span>
    <button :disabled="props.modelValue >= max" @click="inc">＋</button>
  </div>
</template>

<style scoped>
.stepper {
  display: flex;
  align-items: center;
  gap: 12px;
}
.stepper button {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: transparent;
  color: #fff;
  font-size: 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
.stepper button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}
.stepper .val {
  font-size: 16px;
  font-weight: 600;
  min-width: 28px;
  text-align: center;
  color: var(--accent);
}
</style>
