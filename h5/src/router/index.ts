import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import TasksView from '../views/TasksView.vue'
import StatsView from '../views/StatsView.vue'
import SettingsView from '../views/SettingsView.vue'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    { path: '/', name: 'home', component: HomeView, meta: { showTab: true } },
    { path: '/tasks', name: 'tasks', component: TasksView, meta: { showTab: true } },
    {
      path: '/stats',
      name: 'stats',
      component: StatsView,
      meta: { showTab: true },
    },
    {
      path: '/settings',
      name: 'settings',
      component: SettingsView,
      meta: { showTab: false },
    },
  ],
})

export default router
