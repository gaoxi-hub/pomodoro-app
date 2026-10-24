<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useSettingsStore } from '../stores/settings'
import { useToast } from '../composables/useToast'
import Switch from '../components/Switch.vue'
import Stepper from '../components/Stepper.vue'

const router = useRouter()
const settings = useSettingsStore()
const toast = useToast()

function save() {
  toast.show('设置已保存')
  router.back()
}
</script>

<template>
  <div class="set">
    <div class="topbar">
      <button class="back" @click="router.back()">↩︎</button>
      <h1>设置</h1>
      <span class="spacer"></span>
    </div>

    <div class="set-card">
      <div class="set-row">
        <div class="lbl">工作时长<small>单个番茄分钟数</small></div>
        <Stepper
          :model-value="settings.settings.workMin"
          :min="1"
          :max="90"
          @update:model-value="(v: number) => settings.update({ workMin: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">短休息<small>每轮工作后</small></div>
        <Stepper
          :model-value="settings.settings.shortMin"
          :min="1"
          :max="30"
          @update:model-value="(v: number) => settings.update({ shortMin: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">长休息<small>长休分钟数</small></div>
        <Stepper
          :model-value="settings.settings.longMin"
          :min="1"
          :max="60"
          @update:model-value="(v: number) => settings.update({ longMin: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">长休间隔<small>每几个番茄后长休</small></div>
        <Stepper
          :model-value="settings.settings.longBreakInterval"
          :min="1"
          :max="8"
          @update:model-value="(v: number) => settings.update({ longBreakInterval: v })"
        />
      </div>
    </div>

    <div class="set-card">
      <div class="set-row">
        <div class="lbl">自动开始下一轮</div>
        <Switch
          :model-value="settings.settings.autoStartNext"
          @update:model-value="(v: boolean) => settings.update({ autoStartNext: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">休息结束提醒</div>
        <Switch
          :model-value="settings.settings.breakEndNotify"
          @update:model-value="(v: boolean) => settings.update({ breakEndNotify: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">完成庆祝动效</div>
        <Switch
          :model-value="settings.settings.celebrate"
          @update:model-value="(v: boolean) => settings.update({ celebrate: v })"
        />
      </div>
      <div class="set-row">
        <div class="lbl">提示音</div>
        <Switch
          :model-value="settings.settings.soundOn"
          @update:model-value="(v: boolean) => settings.update({ soundOn: v })"
        />
      </div>
    </div>

    <div class="set-card">
      <div class="set-row">
        <div class="lbl">每日番茄目标<small>默认 8 个</small></div>
        <Stepper
          :model-value="settings.goal.dailyPomodoros"
          :min="1"
          :max="30"
          @update:model-value="(v: number) => settings.updateGoal(v)"
        />
      </div>
    </div>

    <button class="save" @click="save">保存设置</button>
  </div>
</template>

<style scoped>
.topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 0 -20px 18px;
  padding: 10px 20px 12px;
  background: #000;
}
.topbar h1 {
  font-size: 30px;
  font-weight: 700;
  letter-spacing: -0.5px;
}
.back {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #fff;
  font-size: 18px;
}
.spacer {
  width: 44px;
}
.set-card {
  background: var(--card-bg);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: var(--radius-card);
  padding: 6px 18px;
  margin-bottom: 16px;
}
.set-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
.set-row:last-child {
  border-bottom: none;
}
.set-row.col {
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
}
.set-row .lbl {
  font-size: 15px;
}
.set-row .lbl small {
  display: block;
  font-size: 12px;
  color: var(--text-tertiary);
  margin-top: 2px;
}
.save {
  width: 100%;
  padding: 15px;
  border-radius: var(--radius-pill);
  background: var(--accent-gradient);
  color: #04201a;
  font-weight: 700;
  font-size: 15px;
  border: none;
  margin-top: 8px;
  box-shadow: var(--glow-accent);
}
</style>
