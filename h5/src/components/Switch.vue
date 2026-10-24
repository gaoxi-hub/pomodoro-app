<script setup lang="ts">
const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits<{ 'update:modelValue': [value: boolean] }>()

function toggle() {
  emit('update:modelValue', !props.modelValue)
}
</script>

<template>
  <div
    class="switch"
    :class="{ on: props.modelValue }"
    role="switch"
    :aria-checked="props.modelValue"
    @click="toggle"
  >
    <i></i>
  </div>
</template>

<style scoped>
.switch {
  width: 50px;
  height: 30px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.15);
  position: relative;
  cursor: pointer;
  transition: 0.25s;
  flex: 0 0 auto;
}
.switch.on {
  background: var(--accent);
  box-shadow: var(--glow-soft);
}
.switch i {
  position: absolute;
  top: 3px;
  left: 3px;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #fff;
  transition: 0.25s;
}
.switch.on i {
  left: 23px;
}
</style>
