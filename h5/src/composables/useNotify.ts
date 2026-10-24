function request(): void {
  if (typeof Notification === 'undefined') return
  if (Notification.permission === 'default') {
    void Notification.requestPermission().catch(() => {
      /* 用户拒绝，忽略 */
    })
  }
}

function notify(title: string, body: string): void {
  if (typeof Notification === 'undefined') return
  if (Notification.permission === 'granted') {
    try {
      new Notification(title, { body })
    } catch {
      /* noop */
    }
  }
}

export function useNotify() {
  return { request, notify }
}
