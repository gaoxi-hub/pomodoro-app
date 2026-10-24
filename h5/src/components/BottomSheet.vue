<script setup lang="ts">
const props = defineProps<{ modelValue: boolean; title?: string }>()
const emit = defineEmits<{ 'update:modelValue': [value: boolean] }>()

function close() {
  emit('update:modelValue', false)
}
</script>

<template>
  <Teleport to="body">
    <transition name="sheet-fade">
      <div v-if="props.modelValue" class="mask" @click.self="close">
        <transition name="sheet-up" appear>
          <div v-if="props.modelValue" class="sheet">
            <div class="grab"></div>
            <h3 v-if="props.title">{{ props.title }}</h3>
            <slot />
          </div>
        </transition>
      </div>
    </transition>
  </Teleport>
</template>

<style scoped>
.mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(2px);
  z-index: 100;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}
.sheet {
  width: 100%;
  max-width: 480px;
  background: #0c1310;
  border-top-left-radius: 28px;
  border-top-right-radius: 28px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-bottom: none;
  padding: 18px 22px calc(28px + env(safe-area-inset-bottom));
  box-shadow: 0 -10px 40px rgba(0, 0, 0, 0.6);
}
.grab {
  width: 40px;
  height: 5px;
  border-radius: 3px;
  background: rgba(255, 255, 255, 0.25);
  margin: 0 auto 16px;
}
.sheet h3 {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 4px;
}
.sheet-fade-enter-active,
.sheet-fade-leave-active {
  transition: opacity 0.25s ease;
}
.sheet-fade-enter-from,
.sheet-fade-leave-to {
  opacity: 0;
}
.sheet-up-enter-active,
.sheet-up-leave-active {
  transition: transform 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
}
.sheet-up-enter-from,
.sheet-up-leave-to {
  transform: translateY(100%);
}
</style>
