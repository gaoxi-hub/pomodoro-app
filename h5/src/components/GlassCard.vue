<script setup lang="ts">
defineProps<{ pad?: boolean }>()
</script>

<template>
  <div class="glass card" :class="{ 'no-pad': !pad }">
    <slot />
  </div>
</template>

<style scoped>
.card {
  padding: 16px 18px;
}
.card.no-pad {
  padding: 0;
}
</style>
